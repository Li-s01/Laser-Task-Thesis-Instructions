"""
moving_average_check.py
"""
import numpy as np
import csv
import plotly.graph_objects as go


#load data
def load_block_csv(path):
    true_pos, obs_pos = [], []
    with open(path) as f:
        reader = csv.DictReader(f)
        for row in reader:
            true_pos.append(float(row['true_pos']))
            obs_pos.append(float(row['obs_pos']))
    return np.array(true_pos), np.array(obs_pos)


# extract real sample and not just frams
def extract_distinct_samples(obs_pos):
    sample_values = [obs_pos[0]]
    sample_start_frames = [0]
    for i in range(1, len(obs_pos)):
        if obs_pos[i] != obs_pos[i - 1]:
            sample_values.append(obs_pos[i])
            sample_start_frames.append(i)
    return np.array(sample_values), np.array(sample_start_frames)


# one blocked average weighte
def circular_block_average_per_sample(obs_pos, block_size=3, weights=None):
   
    sample_values, sample_starts = extract_distinct_samples(obs_pos)
    n_samples = len(sample_values)

    block_avgs = []
    block_first_sample_idx = []

    for start in range(0, n_samples, block_size):
        end = min(start + block_size, n_samples)
        chunk = sample_values[start:end]
        radians = np.deg2rad(chunk)
        sins = np.sin(radians)
        coss = np.cos(radians)

        if weights is not None and len(chunk) == block_size:
            w = np.array(weights, dtype=float)
            w = w / w.sum()
            sin_mean = np.sum(sins * w)
            cos_mean = np.sum(coss * w)
        else:
            
            sin_mean = np.mean(sins)
            cos_mean = np.mean(coss)

        block_avgs.append(np.rad2deg(np.arctan2(sin_mean, cos_mean)) % 360)
        block_first_sample_idx.append(start)

    total_frames = len(obs_pos)
    expanded = np.zeros(total_frames)

    # First calculates all frame_starts 
    frame_starts = []
    for i in range(len(block_avgs)):
        last_sample_in_block = min(
            block_first_sample_idx[i] + block_size - 1,
            len(sample_starts) - 1
        )
        frame_starts.append(int(sample_starts[last_sample_in_block]))

    # fill up
    for i, value in enumerate(block_avgs):
        frame_start = frame_starts[i]
        if i + 1 < len(frame_starts):
            frame_end = frame_starts[i + 1]
        else:
            frame_end = total_frames
        expanded[frame_start:frame_end] = value

    return expanded



#Plotly                               
def plot_comparison_interactive(csv_path, output_html_path, title=''):
    true_pos, obs_pos = load_block_csv(csv_path)
    frames = list(range(len(true_pos)))

    weights_3 = [0.1, 0.3, 0.6]        # t-3, t-2, t-1
    weights_4 = [0.1, 0.2, 0.3, 0.4]   # t-4, t-3, t-2, t-1

    block_avg_3 = circular_block_average_per_sample(
        obs_pos, block_size=3, weights=weights_3
    )
    block_avg_4 = circular_block_average_per_sample(
        obs_pos, block_size=4, weights=weights_4
    )

    fig = go.Figure()

    fig.add_trace(go.Scattergl(
        x=frames, y=true_pos, mode='lines',
        name='True mean',
        line=dict(color='red', width=3)
    ))

    fig.add_trace(go.Scattergl(
        x=frames, y=obs_pos, mode='lines',
        name='Observations',
        line=dict(color='black', width=0.7),
        opacity=1.0
    ))

    fig.add_trace(go.Scattergl(
        x=frames, y=block_avg_3, mode='lines',
        name='moving average (weighted, every 3th sample)',
        line=dict(color='royalblue', width=2)
    ))

    fig.add_trace(go.Scattergl(
        x=frames, y=block_avg_4, mode='lines',
        name='moving average (weighted, every 4th sample)',
        line=dict(color='seagreen', width=2)
    ))

    fig.update_layout(
        title=title,
        xaxis_title='Frame',
        yaxis_title='Angle (°)',
        hovermode='x unified',
        template='plotly_white'
    )

    fig.write_html(output_html_path)
    print(f"Gespeichert: {output_html_path}")



if __name__ == '__main__':
    import os
    import config

    seq_dir = config.OUTPUT_DIR

    # --- two practice sequences ---
    plot_comparison_interactive(
        os.path.join(seq_dir, 'practice_cp_volatile_block1.csv'),
        os.path.join(seq_dir, 'practice_cp_volatile_movavg.html'),
        title='Practice CP (volatile)'
    )
    plot_comparison_interactive(
        os.path.join(seq_dir, 'practice_cp_noise_block1.csv'),
        os.path.join(seq_dir, 'practice_cp_noise_movavg.html'),
        title='Practice CP (noise)'
    )

    # --- ambiguous change-point, block 1 ---
    plot_comparison_interactive(
        os.path.join(seq_dir, 'ambiguous_cp_block1.csv'),
        os.path.join(seq_dir, 'ambiguous_cp_block1_movavg.html'),
        title='CP-ambig block 1'
    )

    # --- ambiguous change-point score3, block 1 (local sequences/ folder) ---
    local_seq_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'sequences')
    plot_comparison_interactive(
        os.path.join(local_seq_dir, 'ambiguous_cp_score3_block1.csv'),
        os.path.join(local_seq_dir, 'ambiguous_cp_score3_block1_movavg.html'),
        title='CP-ambig score3 block 1'
    )