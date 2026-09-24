"""
Selects the best ambiguous sequences (change-point and random walk).
For each type, the script makes 50 sequences with different seeds.
For each sequence, it computes a moving average of the observations and
finds periods where this average is far away from the true mean
(more than half the shield size). Sequences with many long periods
get a high score.
"""
import numpy as np
import plotly.graph_objects as go
from generate_ambiguous_cp_session import generate_ambiguous_cp_session
from generate_ambiguous_rw_session import generate_ambiguous_rw_session
from moving_average_check import (
    extract_distinct_samples,
    circular_block_average_per_sample
)
import os
import csv
import config


#  Parameter                                                            
N_SEQUENCES    = 50
N_BEST         = 4
SHIELD_SIZE   = 20          # Grad
THRESHOLD      = SHIELD_SIZE / 2   # = 10°
BLOCK_SIZE     = 3
WEIGHTS       = [0.1, 0.3, 0.6]
OUTPUT_DIR     = 'sequences'
PLOT_DIR      = 'sequences/selection_plots'
NOISE_STD_AMBIGUOUS_CP = config.NOISE_STD_AMBIGUOUS_CP
SIGMA_OBS_AMBIGUOUS_RW = config.SIGMA_OBS_AMBIGUOUS_RW


# substract the two angles on circle
def circular_difference(avg, true_pos):
    diff = (avg - true_pos + 180) % 360 - 180
    return diff


# finds all the periods, where the difference between moving_average 
# and the true mean is bigger than the threshold
def find_periods(diff, threshold=THRESHOLD):
    abs_diff = np.abs(diff)
    durations =[]
    starts = []
    ends = []

    in_period = False
    period_start = 0
    period_sign = 0  # +1 or -1, tracks direction of current period

    for i, d in enumerate(abs_diff):
        current_sign = int(np.sign(diff[i]))

        if d > threshold and not in_period:
            # start new period
            in_period = True
            period_start = i
            period_sign = current_sign

        elif in_period:
            if d <= threshold:
                # period ends: fell below threshold
                in_period = False
                durations.append(i - period_start)
                starts.append(period_start)
                ends.append(i)

            elif current_sign != period_sign:
                # period ends: direction flipped
                #end current period here
                durations.append(i - period_start)
                starts.append(period_start)
                ends.append(i)
                # immediately start new period in new direction
                period_start = i
                period_sign = current_sign

    # last period if it lasts until the end
    if in_period:
        durations.append(len(diff) - period_start)
        starts.append(period_start)
        ends.append(len(diff))

    MIN_DURATION= 30
    filtered = [(d, s, e) for d, s, e in zip(durations, starts, ends) if d >= MIN_DURATION]
    if filtered:
        durations, starts, ends = zip(*filtered)
        durations = list(durations)
        starts    = list(starts)
        ends    = list(ends)
    else:
        durations, starts, ends = [], [], []


    return durations, starts, ends


# computes median for each sequence duration list and counts how many periods that are over the thershold there are
def compute_metric(durations):
    if len(durations) == 0:
        return 0.0, 0
    return float(np.median(durations)), len(durations)


# plot for sequences
def plot_sequence(result, output_path):
    frames = list(range(len(result['diff'])))

    fig = go.Figure()

    # difference line
    fig.add_trace(go.Scattergl(
        x=frames, y=result['diff'].tolist(),
        name='MA - True Mean',
        line=dict(color='royalblue', width=1.5)
    ))
    fig.add_trace(go.Scattergl(
        x=frames, y=result['diff_obs'].tolist(),
        name='Observations − True Mean',
        line=dict(color='grey', width=0.7),
        opacity=0.5
    ))
    # thershold line
    fig.add_hline(y=THRESHOLD,
                  line=dict(color='red', dash='dash', width=1.2),
                  annotation_text=f'+{THRESHOLD}°')
    fig.add_hline(y=-THRESHOLD,
                  line=dict(color='red', dash='dash', width=1.2),
                  annotation_text=f'−{THRESHOLD}°')

    
    for idx, (s, e) in enumerate(zip(result['period_starts'], result['period_ends'])):
            color = 'orange' if idx % 2 == 0 else 'lightgreen'
            fig.add_vrect(x0=s, x1=e,
                        fillcolor=color, opacity=0.25,
                        line_width=0)

    fig.update_layout(
        title=(f"Seed {result['seed']} | "
               f"Median: {result['median']:.0f} frames | "
               f"Count: {result['count']} | "
               f"Score: {result['score3']:.1f}"),
        xaxis_title='Frame',
        yaxis_title='Differenz MA − True Mean (°)',
        yaxis=dict(range=[-90, 90]),
        template='plotly_white',
        hovermode='x unified'
    )

    fig.write_html(output_path)
    print(f"  Plot gespeichert: {output_path}")


def plot_duration_histogram(result, output_path):
    durations = result['durations']
    
    fig = go.Figure()
    
    fig.add_trace(go.Histogram(
        x=durations,
        nbinsx=20,
        marker_color='royalblue',
        opacity=0.75,
        name='Period durations'
    ))
    # Median as vertical line
    fig.add_vline(
        x=result['median'],
        line=dict(color='red', dash='dash', width=2),
        annotation_text=f"Median: {result['median']:.0f} frames"
    )
    
    fig.update_layout(
        title=(f"Seed {result['seed']} — Duration Distribution | "
            f"Count: {result['count']} | "
            f"Median: {result['median']:.0f} frames"),
        xaxis_title='Period duration (frames)',
        yaxis_title='Count',
        template='plotly_white'
    )
    
    fig.write_html(output_path)
    print(f"  Histogram gespeichert: {output_path}")


# writes a nlock-csv in the same format as write_session_to_csv_file 
def write_block_csv(true_pos, obs_pos, file_path, noise_std):
    std_deg = noise_std * np.ones(len(true_pos))
    with open(file_path, 'w') as f:
        f.write('true_pos,obs_pos,true_var\n')
        for j in range(len(true_pos)):
            f.write(f'{int(true_pos[j])},{int(obs_pos[j])},{int(std_deg[j])}\n')


# rotates all angles in a CSV by rotation_deg degrees on the circle
def rotate_sequence(input_csv, output_csv, rotation_deg):
    rows = []
    with open(input_csv) as f:
        reader = csv.DictReader(f)
        for row in reader:
            rows.append({
                'true_pos': int((float(row['true_pos']) + rotation_deg) % 360),
                'obs_pos':  int((float(row['obs_pos'])  + rotation_deg) % 360),
                'true_var': row['true_var']
            })
    with open(output_csv, 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=['true_pos', 'obs_pos', 'true_var'])
        writer.writeheader()
        writer.writerows(rows)
    print(f"  Rotierte CSV gespeichert: {output_csv}")


# main 

if __name__ == '__main__':
    os.makedirs(PLOT_DIR, exist_ok=True)

    #CP ------                                                              
    results = []

    for seed in range(N_SEQUENCES):
        np.random.seed(seed)

        #generate sequences 
        session = generate_ambiguous_cp_session(
            n_blocks=1,
            session_file_name=f'_tmp_seed{seed}',
            output_dir='sequences/_tmp'
        )

        true_pos = session['blocks'][0]['stim']['meanValueVectorDeg']
        obs_pos  = session['blocks'][0]['stim']['valueVectorDeg']

        # calculate moving average
        avg = circular_block_average_per_sample(
            obs_pos, block_size=BLOCK_SIZE, weights=WEIGHTS
        )

        # difference
        diff = circular_difference(avg, true_pos)
        diff_obs = circular_difference(obs_pos, true_pos)  # raw observations version
        # finds periods
        durations, starts, ends = find_periods(diff)

        # mean, count, score
        median, count = compute_metric(durations)
        score3 = sum(d**2 for d in durations)



        results.append({
            'seed':          seed,
            'true_pos':      true_pos,
            'obs_pos':       obs_pos,
            'diff':          diff,
            'diff_obs':      diff_obs,
            'durations':     durations,
            'period_starts': starts,
            'period_ends':   ends,
            'median':        median,
            'count':         count,
            'score3':        score3,

        })

        print(f"  Seed {seed:02d}: Median={median:5.1f} frames, "
              f"Count={count:3d}, Score={score3:7.1f}")


    # sort for score3 (sum of squared durations)
    results_by_score3 = sorted(results, key=lambda x: x['score3'], reverse=True)
    best_score3 = results_by_score3[:N_BEST]


    print(f"\nTop {N_BEST} nach Score3 (sum of squared durations):")
    for rank, r in enumerate(best_score3, 1):
        print(f"  Rang {rank}: Seed={r['seed']}, Score3={r['score3']:.1f}")

    

    # plots 4 best sequences score3
    for rank, r in enumerate(best_score3, 1):
        plot_sequence(r, os.path.join(PLOT_DIR, f'best_score3_{rank}_seed{r["seed"]}.html'))
        plot_duration_histogram(r, os.path.join(PLOT_DIR, f'best_score3_{rank}_seed{r["seed"]}_hist.html'))

        # save original CSV
        csv_path = os.path.join(OUTPUT_DIR, f'ambiguous_cp_final_block{rank}.csv')
        write_block_csv(r['true_pos'], r['obs_pos'], csv_path, NOISE_STD_AMBIGUOUS_CP)

        # save rotated CSV for second repetition (same sequence, shifted by 180° on the circle)
        rotated_path = os.path.join(OUTPUT_DIR, f'ambiguous_cp_final_block{rank}_rot180.csv')
        rotate_sequence(csv_path, rotated_path, rotation_deg=180)

    
    #  RW ----                                                               
    print("\n--- RW Sequences ---")
    results_rw = []

    for seed in range(N_SEQUENCES):
        np.random.seed(seed)

        session = generate_ambiguous_rw_session(
            n_blocks=1,
            session_file_name=f'_tmp_rw_seed{seed}',
            output_dir='sequences/_tmp'
        )

        true_pos = session['blocks'][0]['stim']['meanValueVectorDeg']
        obs_pos  = session['blocks'][0]['stim']['valueVectorDeg']

        # calculate moving average
        avg = circular_block_average_per_sample(
            obs_pos, block_size=BLOCK_SIZE, weights=WEIGHTS
        )

        # difference
        diff = circular_difference(avg, true_pos)
        diff_obs= circular_difference(obs_pos, true_pos)  # raw observations version

        # finds periods
        durations, starts, ends = find_periods(diff)

        # mean, count, score
        median, count = compute_metric(durations)
        score3 = sum(d**2 for d in durations)

        results_rw.append({
            'seed':          seed,
            'true_pos':      true_pos,
            'obs_pos':       obs_pos,
            'diff':          diff,
            'diff_obs':      diff_obs,
            'durations':     durations,
            'period_starts': starts,
            'period_ends':   ends,
            'median':        median,
            'count':         count,
            'score3':        score3,
        })

        print(f"  Seed {seed:02d}: Median={median:5.1f} frames, "
              f"Count={count:3d}, Score={score3:7.1f}")


    results_rw_by_score3 = sorted(results_rw, key=lambda x: x['score3'], reverse=True)

    best_rw_score3 = results_rw_by_score3[:N_BEST]


    print(f"\nTop {N_BEST} RW nach Score3 (sum of squared durations):")
    for rank, r in enumerate(best_rw_score3, 1):
        print(f"  Rang {rank}: Seed={r['seed']}, Score3={r['score3']:.1f}")


    for rank, r in enumerate(best_rw_score3, 1):
        plot_sequence(r, os.path.join(PLOT_DIR, f'rw_best_score3_{rank}_seed{r["seed"]}.html'))
        plot_duration_histogram(r, os.path.join(PLOT_DIR, f'rw_best_score3_{rank}_seed{r["seed"]}_hist.html'))

        # save original CSV
        rw_csv_path = os.path.join(OUTPUT_DIR, f'ambiguous_rw_final_block{rank}.csv')
        write_block_csv(r['true_pos'], r['obs_pos'], rw_csv_path, SIGMA_OBS_AMBIGUOUS_RW)

        # save rotated CSV for second repetition (same sequence, shifted by 180° on the circle)
        rw_rotated_path = os.path.join(OUTPUT_DIR, f'ambiguous_rw_final_block{rank}_rot180.csv')
        rotate_sequence(rw_csv_path, rw_rotated_path, rotation_deg=180)

                                                     
    import shutil
    tmp_dir = 'sequences/_tmp'
    if os.path.exists(tmp_dir):
        shutil.rmtree(tmp_dir)