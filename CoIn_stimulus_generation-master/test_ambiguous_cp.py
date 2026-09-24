"""
Generates and plots an ambiguous CP session 
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

from generate_ambiguous_cp_session import generate_ambiguous_cp_session
from plot_session import plot_session
from analyse_session import analyse_session
import os

os.makedirs('sequences', exist_ok=True)

session = generate_ambiguous_cp_session(
    n_blocks=4,
    session_file_name='ambiguous_cp',
    output_dir='sequences'
)

print(f"blocks generated: {session['nBlocks']}")
print(f"block-Typ: {session['design']['blockTypes']}")
print(f"Noise Std: {session['design']['blocks'][0]['noiseStd']}")
print(f"Jump Values: {session['design']['blocks'][0]['jumpValueSet']}")

fh = plot_session(session, 0)
fh.savefig('sequences/ambiguous_cp_plot.png', dpi=150)
plt.close('all')

fh1, fh2 = analyse_session(session)
fh1.savefig('sequences/ambiguous_cp_move.png', dpi=150)
fh2.savefig('sequences/ambiguous_cp_steps.png', dpi=150)
plt.close('all')

print("Plots saved in sequences/")