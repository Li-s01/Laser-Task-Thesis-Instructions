"""
Generates and plots an ambiguous rw-session
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

from generate_ambiguous_rw_session import generate_ambiguous_rw_session
from plot_session import plot_session
from analyse_session import analyse_session
import os

os.makedirs('sequences', exist_ok=True)

session = generate_ambiguous_rw_session(
    n_blocks=4,
    session_file_name='ambiguous_rw',
    output_dir='sequences'
)

print(f"Blocks generated: {session['nBlocks']}")
print(f"sigmaStream: {session['design']['blocks'][0]['sigmaStream']}")
print(f"sigmaObs: {session['design']['blocks'][0]['sigmaObs']}")

fh = plot_session(session, 0)
fh.savefig('sequences/ambiguous_rw_plot.png', dpi=150)
plt.close('all')

fh1, fh2 = analyse_session(session)
fh1.savefig('sequences/ambiguous_rw_move.png', dpi=150)
fh2.savefig('sequences/ambiguous_rw_steps.png', dpi=150)
plt.close('all')

print("Plots saved in sequences/")