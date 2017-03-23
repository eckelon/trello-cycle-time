import pandas
import matplotlib.pyplot as plt

filename = 'conecta-tareas.csv'
dataset = pandas.read_csv(filename, index_col=0, header=None, parse_dates=True, infer_datetime_format=True, names=["Average Cycle Time"])

print "Data for: %s" % filename
print dataset.describe()

dataset.plot()
dataset.plot.hist()

plt.show()
