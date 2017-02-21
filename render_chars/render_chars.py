#rendering cuneiform characters

import matplotlib.pyplot as plt
import matplotlib.font_manager as fm
fontpath = '../resources/CuneiformComposite.ttf'
properties = fm.FontProperties(fname=fontpath)
plt.rcParams['font.family'] = properties.get_name()

my_dpi=96
start_int = 73728

#renders a character
def render_char(unicodechar, outfile, dpi=my_dpi):
	fig, ax = plt.subplots(1, 1, figsize=(300/dpi, 300/dpi), dpi=dpi)

	#TODO: autoconfigure so text is centered and fits?
	ax.text(0.5, 0.6, unicodechar, size=150, horizontalalignment='center', verticalalignment='center', transform=ax.transAxes)
	ax.axis('off')

	plt.savefig(outfile)

#render characters 
def render_chars(num_chars, outfolder):
	for i in range(start_int, start_int + 10):
		#get unicode character point
		s = "\\U%08x" % i
		uchar = s.decode('unicode-escape')
		outstr = "{}/{}.jpeg".format(outfolder, i)
		render_char(uchar, outstr)
		print "saved to {}".format(outstr)




if __name__=="__main__":
	render_chars(10, 'rendered')