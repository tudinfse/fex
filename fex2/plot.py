from abc import ABCMeta, abstractmethod
import matplotlib.axes as axes
import matplotlib.pyplot as plt
import matplotlib.ticker as plticker


# =============================================================================
# Plot styles
# =============================================================================
# color pallets
class ColorPallets:
    PAIRED = ['#a6cee3', '#1f78b4', '#b2df8a', '#33a02c', '#e31a1c', '#fb9a99']
    PRINTER_FRIENDLY = ['#b2df8a', '#fdae61', '#ffffbf', '#f4a582', '#1f78b4']
    QUALITATIVE_3 = ['#8dd3c7', '#ffffb3', '#bebada']
    QUALITATIVE_4 = ['#8dd3c7', '#ffffb3', '#bebada', '#fb8072']
    QUALITATIVE_5 = ['#8dd3c7', '#ffffb3', '#bebada', '#fb8072', '#80b1d3']
    QUALITATIVE_6 = ['#8dd3c7', '#ffffb3', '#bebada', '#fb8072', '#80b1d3', '#fdb462']
    QUALITATIVE_7 = ['#8dd3c7', '#ffffb3', '#bebada', '#fb8072', '#80b1d3', '#fdb462', '#b3de69']


class AbstractStyle:
    __metaclass__ = ABCMeta
    ax: axes.Axes

    # main method
    def apply(self, ax: axes.Axes):
        self.ax = ax
        self.font()
        self.axes()
        self.edges()
        self.grid()
        self.ticks()
        self.hatching()
        self.legend()
        self.title()
        self.misc()

        return ax

    @abstractmethod
    def font(self):
        pass

    @abstractmethod
    def axes(self):
        pass

    @abstractmethod
    def edges(self):
        pass

    @abstractmethod
    def grid(self):
        pass

    @abstractmethod
    def ticks(self):
        pass

    @abstractmethod
    def hatching(self):
        pass

    @abstractmethod
    def legend(self):
        pass

    @abstractmethod
    def title(self):
        pass

    @abstractmethod
    def misc(self):
        pass


class BasicStyle(AbstractStyle):
    hatches = ("//////", r"\\\\\\", "", "", "")

    def __init__(self, need_hatching=True):
        self.need_hatching = need_hatching
        super(BasicStyle, self).__init__()

    def font(self):
        plt.rcParams['pdf.fonttype'] = 42
        plt.rcParams['ps.useafm'] = True
        plt.rcParams['pdf.use14corefonts'] = True

    def axes(self):
        self.ax.set_facecolor("white")  # background
        self.ax.yaxis.label.set_color('black')
        self.ax.xaxis.label.set_color('black')

    def edges(self):
        for pos in ['top', 'bottom', 'right', 'left']:
            self.ax.spines[pos].set_edgecolor("black")

    def grid(self):
        self.ax.grid(
            color='#E0EEEE',  # azure2 from R
            linewidth="0.6",
            linestyle="-",  # solid line
        )
        self.ax.xaxis.grid(False)  # disable vertical lines
        self.ax.set_axisbelow(True)  # lines in the background

    def ticks(self):
        self.ax.tick_params(
            labelcolor='black',
            which='major',
            direction='out',
            length=3,
            labelsize=9,
            right=False, top=False, bottom=False
        )
        self.ax.tick_params(
            labelcolor='black',
            which='minor',
            direction='out',
            length=0,
            labelsize=9,
            right=False, top=False, bottom=False
        )
        self.ax.tick_params(
            axis='x',
            pad=-1,
        )

    def hatching(self):
        if not self.need_hatching:
            return

        bars = self.ax.patches
        num_groups = len(self.ax.get_xticks())
        hatches = [h for h in self.hatches for n in range(num_groups)]

        for bar, hatch in zip(bars, hatches):
            if hatch:
                bar.set_hatch(hatch)

    def legend(self):
        pass

    def title(self):
        self.ax.set_title(
            self.ax.get_title(),
            {
                'fontsize': 10,
                'fontweight': 'bold',
                'horizontalalignment': "center",
            },
        )

    def misc(self):
        pass


class BarPlotStyle(BasicStyle):
    bar_edge_color = "black"
    colors = ColorPallets.PAIRED
    color_single = ColorPallets.PAIRED[0]
    hatches = ("//////", "", "", r"\\\\\\", "//////",)

    def __init__(self, legend_ncol=5, legend_loc=(0.005, 0.879), **kwargs):
        super(BarPlotStyle, self).__init__(**kwargs)
        self.legend_ncol = legend_ncol
        self.legend_loc = legend_loc

    def ticks(self):
        super(BarPlotStyle, self).ticks()
        self.ax.set_xticklabels(self.ax.xaxis.get_majorticklabels(), rotation=30)

    def legend(self):
        legend = self.ax.legend(
            title=None,
            loc=self.legend_loc,
            frameon=True,
            ncol=self.legend_ncol,
            labelspacing=0,
            columnspacing=1,
            borderpad=0.2,
            handlelength=0.7,
            fontsize=10,
        )
        legend.get_frame().set_facecolor('#ffffff')
        if self.legend_ncol == 1:
            legend.set_visible(False)


class LinePlotStyle(BasicStyle):
    colors = ['#969696', '#a6cee3', '#1f78b4', '#33a02c', '#b2df8a', '#E8F7DA', '#e31a1c', '#fdbf6f']
    markers = ['o', 'v', 'p', 's', '^', '3', '4', 'D', 'H']

    def legend(self):
        self.ax.legend(
            title=None,
            loc="best",
            frameon=True,
            ncol=1,
            labelspacing=0.5,
            columnspacing=1,
            borderpad=0.5,
            handlelength=2,
            fontsize=12,
        ).get_frame().set_facecolor('#ffffff')


# =============================================================================
# Building plots
# =============================================================================
class FexPlot:
    __metaclass__ = ABCMeta
    df = None
    plot: axes.Axes = None
    style_class = None

    def __init__(self, style):
        self.style_class = style

    @abstractmethod
    def build(self, df, metadata_columns, data_column, **kwargs):
        pass

    def savefig(self, file, **kwargs):
        """
        A thin wrapper over fig.savefig from matplotlib.
        Arguments are the same.
        """
        fig = self.plot.get_figure()
        fig.savefig(file, **kwargs)


class BarPlot(FexPlot):
    def __init__(self, style=BarPlotStyle):
        super(BarPlot, self).__init__(style)

    def build(self, df,
              xlabel="",
              ylabel="Overhead w.r.t. native",
              legend_renamings=None,
              legend_loc=None,
              figsize=(12, 2),
              text_points=(),
              vline_position=6,
              title="",
              ncol=5,
              **kwargs):
        style = self.style_class(legend_ncol=ncol, legend_loc=legend_loc, need_hatching=False)
        color = style.colors if ncol != 1 else style.color_single

        plot = df.plot(
            kind="bar",
            figsize=figsize,
            linewidth=0.5,
            edgecolor=[style.bar_edge_color] * 100,
            color=color,
            title=title,
            **kwargs
        )
        plot = style.apply(plot)

        if kwargs.get("logy", False):
            plot.set_yscale('log', basey=2, nonposy='clip')
            plot.yaxis.set_major_formatter(plticker.ScalarFormatter())
            if kwargs.get('yticks'):
                plot.set_yticks(kwargs.get('yticks'))

        # parametrize labels
        plot.set_ylabel(ylabel, fontsize=10)
        plot.set_xlabel("", fontsize=0)  # remove x label

        # vertical line - usually, a delimiter for mean values
        plot.axvline(vline_position, linewidth=0.9, color='grey', dashes=[3, 3])

        # additional text
        for point in text_points:
            plot.text(point[0], point[1], point[2], fontsize=8)

        # save the resulting plot as an object property
        self.plot = plot


class LinePlotThroughput(FexPlot):
    def __init__(self, style=LinePlotStyle):
        super(LinePlotThroughput, self).__init__(style)

    def build(self, df, metadata_columns,
                xlabel=r"Throughput ($\times 10^3$ msg/s)", ylabel="Latency (ms)",
                legend_loc='upper left',
                figsize=(4, 3),
                subplot=None,
                build_names="short",
                title="",
                labels=lambda key: '/'.join(map(str, key)),
                **kwargs):
        style = self.style_class()

        # create a canvas
        plot = subplot

        kwargs.pop('metadata_columns', None)
        kwargs.pop('data_column', None)

        # draw lines, one build type at a time
        idx = 0
        for key, grp in df.groupby(metadata_columns):
            if not grp.empty:
                plot = grp.plot(
                    ax=plot,
                    x="tps",
                    y="latency",
                    kind="line",
                    marker=style.markers[idx % len(style.markers)],
                    markeredgecolor='black',
                    markeredgewidth=0.5,
                    markersize=8,
                    color=style.colors[idx % len(style.colors)],
                    title=title,
                    figsize=figsize,
                    linewidth=3,
                    label=labels(key),
                    **kwargs
                )
                idx += 1

        # apply other styles
        plot = style.apply(plot)
        style.legend()
        plot.xaxis.grid(True)

        plot.tick_params(axis='both', which='major', labelsize=12)

        plot.set_xlabel(xlabel, fontsize=14)
        plot.set_ylabel(ylabel, fontsize=14)

        # save the resulting plot as an object property
        self.plot = plot
