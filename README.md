# diffuserwavefrontsensor
Implements a diffuser-based wavefront sensor in MATLAB after [Berto, et al. 2017](https://www.osapublishing.org/ol/abstract.cfm?uri=ol-42-24-5117). 


### Basic usage
Create an instance of the `diffusersensor` class in the base workspace
```
d=diffusersensor
```

Assuming you have the default compatible camera, a window will now appear with a live stream from the camera sensor. 
If nothing happens, you will need to create a camera function file for your device. 
Go to the `private` directory of the `dws.camera` class and make a new function based on the existing ones. 
The string `camToStart` should now be assigned to the name of your camera.  

Set up your optical system to acquire a reference image then: 
```
d.setReference
```

You will see the reference image overlaid onto the current live image in red/green.
You can calculate the wavefront shape at any time by running:

```
d.getPhase
```

The results are stored in the objects properties. 
Other stuff to try;

```
% Stop and start the video
d.stopVideo 
d.startVideo


% Do a translation correction of the last acquired image to the 
% the reference before calculating the wavefront
d.transCor = true;
d.getPhase

d.transCor = false; % return to default value

% Speed up the calculation
d.resizeBy = 0.5;
d.getPhase


% Calculate the phase shifts only by don't plot
d.calcPhase

% Close the phase display window and re-make it without re-calculating
d.plotWavefront
```

### Settings
To get meaningful numbers in the phase plot you should edit the `dws_settings.m` file so that pixel size, wavelength, and distance to the diffuser are correct. 