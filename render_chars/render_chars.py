#rendering cuneiform characters

import matplotlib.pyplot as plt
import matplotlib.font_manager as fm
import os
import numpy as np
fontpath = 'resources/CuneiformComposite.ttf'
properties = fm.FontProperties(fname=fontpath)
plt.rcParams['font.family'] = properties.get_name()

my_dpi=96
start_int = 73728

#changing this will change threshold for "bad" corners
top_lim = 1.2
bot_lim = -0.2

#renders a character at the given position with the given character size
def render_char(unicodechar, outfile=None, fig_dim=300, dpi=my_dpi, rotation=0,
							char_size=150, pos=(0.5, 0.5), check_clipping=True):
	fig, ax = plt.subplots(1, 1, figsize=(fig_dim/dpi, fig_dim/dpi), dpi=dpi)
	#unpack tuple
	x, y = pos
	t = ax.text(x, y, unicodechar, size=char_size, horizontalalignment='center', verticalalignment='center', transform=ax.transAxes, rotation=rotation)
	plt.axis('off')
	if outfile:
		plt.savefig(outfile)
		print "saved to {}".format(outfile)
		if check_clipping:
			#check if text is inside canvas
			#this is so gross, but there's no way to do this until after it's been rendered
			#half width, and half-height
			width, height = t.get_window_extent().width/fig_dim, t.get_window_extent().height/fig_dim
			#create corner points (with rotation), check if they're all in bounds
			#create corner points with box center as origin, perform rotation, translate back
			corners = [np.array([-width/2, -height/2]), np.array([width/2, -height/2]),
						np.array([-width/2, height/2]), np.array([width/2, height/2])]
			#create rotation matrix
			theta = np.radians(rotation)
			c, s = np.cos(theta), np.sin(theta)
			R = np.array([[c, -s], [s, c]])
			for cnr in corners:
				#rotate corner, translate,
				cnr_prime = R.dot(cnr) + np.array(pos)
				if cnr_prime[0] > top_lim or cnr_prime[0] < bot_lim or cnr_prime[1] > top_lim or cnr_prime[1] < bot_lim:
					print "bad corner, removing"
					os.remove(outfile)
					break
			plt.close()
	else:
		plt.show()


#gets a unicode character for the given code point
def get_unicode_char(i):
	s = "\\U%08x" % i
	return s.decode('unicode-escape')

#render characters
def render_chars(num_chars, outfolder):
	for i in range(start_int, start_int + 10):
		#get unicode character point
		uchar = get_unicode_char(i)
		outstr = "{}/{}.jpeg".format(outfolder, i)
		render_char(uchar, outstr)
		print "saved to {}".format(outstr)

#generates transformation of characters
def generate_transformed_chars(unicodechar, charnum, outfolder, location_offsets=(0.3, 0.3), loc_step=0.1, max_rot=30, rot_step=5, size_range=(120, 180), size_step=10):
	print "generating transformed character"
	#iterating through all offsets
	img_num = 0

	for x_off in np.arange(-location_offsets[0], location_offsets[0], loc_step):
		for y_off in np.arange(-location_offsets[1], location_offsets[1], loc_step):
			for rot in range(-max_rot, max_rot, rot_step):
				for size in range(size_range[0], size_range[1], size_step):
					outstr = "{}/{}_{}.jpeg".format(outfolder, charnum, img_num)
					img_num += 1
					render_char(unicodechar, outstr, rotation=rot, char_size=size, pos=(0.5 + x_off, 0.5 + y_off))

if __name__=="__main__":

	# uchar = get_unicode_char(start_int)
	# render_char(uchar, outfile="test_char.jpeg")
	for i in range(start_int, start_int + 20):
		uchar = get_unicode_char(i)
		generate_transformed_chars(uchar, i, 'rendered_perm')
