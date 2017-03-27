import os
from collections import OrderedDict
from datetime import datetime

import pandas as pd
import matplotlib.pyplot as plt
import jinja2

class Result(object):

    def __init__(self, period, cycle_time, throughput):
        self.period = period
        self._cycle_time = cycle_time
        self.throughput = throughput

    @property
    def cycle_time(self):
        return self._cycle_time / 3600

    def __str__(self):
        return 'cycle_time: {0} throughput: {1}'.format(self.cycle_time, self.throughput)


def render(template_path, **context):
    path, filename = os.path.split(template_path)
    return jinja2.Environment(
        loader=jinja2.FileSystemLoader(path or './')
    ).get_template(filename).render(context)


filename = 'conecta-tareas-closed-tasks.csv'

dataset = pd.read_csv(filename, parse_dates=True, infer_datetime_format=True)

grouped = dataset.groupby('finished_on_week')
weeks = [name for name, groups in dataset.groupby('finished_on_week')]

results = [
    Result(
        weeks[-1],
        grouped.get_group(weeks[-1])['cycle_time'].mean(),
        grouped.get_group(weeks[-1])['id'].count()
    ),
    Result(
        " | ".join([weeks[-4], weeks[-3], weeks[-2]]),
        pd.concat([grouped.get_group(weeks[-4]), grouped.get_group(weeks[-3]), grouped.get_group(weeks[-2])])['cycle_time'].mean(),
        pd.concat([grouped.get_group(weeks[-4]).count(), grouped.get_group(weeks[-3]).count(), grouped.get_group(weeks[-2]).count()]).mean()
    ),
    Result(
        "total",
        dataset['cycle_time'].mean(),
        dataset['id'].count() / len(weeks)
    )
]

cycle_time_trend = grouped['cycle_time'].agg(lambda x: x.mean() / 3600).to_dict()
throughput_trend = grouped['id'].agg(lambda x: x.count()).to_dict()

r = render('report.j2',
           board_name='Conecta - Tareas',
           results=results,
           now=datetime.now(),
           cycle_time_trend=OrderedDict(sorted(cycle_time_trend.items())),
           throughput_trend=OrderedDict(sorted(throughput_trend.items()))
           )
print r

#print dataset.describe()

#dataset.plot()
#dataset.plot.hist()
#
#plt.show()
