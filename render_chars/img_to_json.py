#converts folder of images to JSON containing greyscale pixel intensities

from PIL import Image
import numpy as np
from os import listdir
import json


#takes in an image path, returns a flattened array with grayscale pixel values
def img_to_list(imgfile):
	img = Image.open(imgfile).convert('L')
	img_array = np.asarray(img, dtype=np.uint8).flatten()
	return img_array


def folder_to_json(imgfolder, outfile):

	json_data = []

	for filename in listdir(imgfolder):
		if filename.endswith(".jpeg"): #only operate on JPEG files
			print "loading {}".format(filename)
			img_array = img_to_list("{}/{}".format(imgfolder, filename))
			file_id = filename.split(".")[0]
			json_data.append({"id": file_id, "vec": img_array.tolist()})

	with open(outfile, 'w') as jsonfile:
		json.dump(json_data, jsonfile)




if __name__=="__main__":
	folder_to_json('rendered', "json_images.json")