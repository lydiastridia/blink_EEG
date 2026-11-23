"""Purpose: draws the convergence graph of the calibration: the mask contrast of both staircases
over the calibration trials.
The open circles mark the reversals and the dashed line is the threshold,
the dotted lines are the mask contrasts for the main task. The graph is saved as a .png file.

Input:  fileName           where to save the picture
        name               participant and session, for the title (e.g. P3_S1)
        maskC              mask contrast of each staircase trial ('a' and 'b')
        trialNumber        calibration trial number of each staircase trial
        reversalPosition   which staircase trials were reversals
        threshold, unseen, seen   threshold and the two contrasts for the main task
"""


def plot_convergence(fileName, name, maskC, trialNumber, reversalPosition, threshold, unseen, seen):
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
    except Exception:
        print('matplotlib not available: no convergence graph was made.')
        return
    fig = plt.figure(figsize=(9, 5))
    ax = fig.add_subplot(111)
    for stair, color, label in (('a', '#D95319', 'staircase a (start 0.95)'),
                                ('b', '#0072BD', 'staircase b (start 0.05)')):
        x = trialNumber[stair]
        y = maskC[stair][:len(x)]
        ax.plot(x, y, '-o', color=color, label=label, markersize=5)
        rx = [x[c - 1] for c in reversalPosition[stair]]
        ry = [y[c - 1] for c in reversalPosition[stair]]
        ax.plot(rx, ry, 'o', color=color, markerfacecolor='white', markersize=6)  # reversals: open circles
    ax.axhline(threshold, color='k', linestyle='--')
    ax.text(1, threshold + 0.01, 'threshold %.2f' % threshold)
    ax.axhline(unseen, color='gray', linestyle=':')
    ax.text(1, unseen + 0.01, 'main task, unseen blocks %.2f' % unseen)
    ax.axhline(seen, color='gray', linestyle=':')
    ax.text(1, seen + 0.01, 'main task, seen blocks %.2f' % seen)
    ax.set_xlabel('Calibration trial')
    ax.set_ylabel('Mask contrast')
    ax.set_ylim(-0.05, 1.05)
    ax.set_title('Calibration ' + name)
    ax.legend(loc='upper right')
    fig.savefig(fileName, dpi=150)
    plt.close(fig)
