from datetime import datetime
from collections import namedtuple

import pandas as pd
import matplotlib.pyplot as plt

class Result(object):

    def __init__(self, cycle_time, throuhgput):
        self._cycle_time = cycle_time
        self.throughput = throughput

    @property
    def cycle_time(self):
        self._cycle_time = cycle_time / 3600


filename = 'conecta-tareas-closed-tasks.csv'
print "Data for: %s" % filename

dataset = pd.read_csv(filename, parse_dates=True, infer_datetime_format=True)#, index_col=0, parse_dates=True, infer_datetime_format=True)

grouped = dataset.groupby('finished_on_week')
weeks = [name for name, groups in dataset.groupby('finished_on_week')]


cycle_times = {
    'last_week': grouped.get_group(weeks[-1])['cycle_time'].mean() / 3600,
    'latest_three_weeks': pd.concat([grouped.get_group(weeks[-4]), grouped.get_group(weeks[-3]), grouped.get_group(weeks[-2])])['cycle_time'].mean() / 3600,
    'total':  dataset['cycle_time'].mean() / 3600
}
print cycle_times

throughputs = {
    'last_week': grouped.get_group(weeks[-1])['id'].count(),
    'latest_three_weeks': pd.concat([grouped.get_group(weeks[-4]).count(), grouped.get_group(weeks[-3]).count(), grouped.get_group(weeks[-2]).count()]).mean(),
    'total':  dataset['id'].count() / len(weeks)
}

print throughputs


#print dataset.describe()

#dataset.plot()
#dataset.plot.hist()
#
#plt.show()
