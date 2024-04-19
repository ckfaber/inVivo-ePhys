# Configure Matlab - Windows
To ensure all code functions seamlessly across different devices and operating systems, please do the following:

## 1) Ensure you are running MATLAB R2022a or newer
Code may work for previous versions, but use at your own peril.

## 2) If you don't already have one, create a MATLAB project folder. From MATLAB command window:
Replace 'username' below with the name of your Windows user profile.

```
cd('C:\Users\username')
mkdir('MATLAB')
```

## 3) Download required functions and SDKS
You will need the Signal Processing Toolkit, and Plexon's Offline Analysis SDK.

### Install the Signal Processing Toolkit: 
- 
- 

### Install Plexon's SDK:
- Visit https://plexon.com/software-downloads/#software-downloads-SDKs, click "OmniPlex and MAP Offline (For reading previously recorded data files)", then "OmniPlex and MAP Offline SDK Bundle" to download the zip. 
- Extract the zip and open it. 
- Extract the "Matlab Offline Files SDK", and move the folder into your new MATLAB folder from step 2.

## 4) Set your MATLAB userpath and initial working folder

### Initial working folder:
In MATLAB, go to Preferences > General > Initial working folder. Enter the path to the new MATLAB directory we made in step 2: C:\Users\username\MATLAB

Click Apply, then OK.

### MATLAB userpath
By default, MATLAB sets your userpath to be 'C:\Users\username\Documents\MATLAB'. We will change this to be the new folder we made in step 2 above. 

```
# Modify userpath
mypath = 'C:\Users\username\MATLAB';
userpath(mypath)

# Confirm change
userpath
```

## 5) Set your MATLAB searchpath

```
addpath(userpath)
```

## 6) (Optional, but recommended) Create a startup.m file in your initial working folder to customize how MATLAB starts
When MATLAB starts, it will automatically detect and run anything contained in the startup.m file located in your default working folder. If you don't already have a startup.m, create one from the Command Window with: 

```
edit startup.m
```

In the Editor window that opens, you can enter everything you want MATLAB to execute on startup. Mine looks like this: 

```
# Refresh search path with new files and subfolders
mypath = userpath;
addpath(genpath(mypath),'-end')

# Dock new figures
set(0,'DefaultFigureWindowStyle','docked')

# Set default color scheme to 'jet'
set(0, 'DefaultFigureColormap',jet)

# Greet yourself!
fprintf(1,'Your message here!\n')
```

