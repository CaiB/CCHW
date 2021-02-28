import random
import math

def CCtoHEX(note, sat, value) :
    hue = -1

    note = (note % 1.0) * 12.0
    if (note < 4) :                 # YELLOW -> RED
        hue = (4.0 - note) * 15.0
    elif (note < 8) :               # RED -> BLUE
        hue = (4.0 - note) * 30.0
    else :                          # BLUE -> YELLOW
        hue = (12.0 - note) * 45.0 + 60.0
    
    return HsvToRGB(hue, sat, value)

def HsvToRGB(hue, sat, value) :
    while (hue < 0) :
        hue += 360
    while (hue > 360) :
        hue -= 360

    R = -1
    G = -1
    B = -1

    if (value <= 0) :
        R = 0
        G = 0
        B = 0
    elif (sat <= 0) :
        R = value
        G = value
        B = value
    else :
        huef = hue/60.0
        i = math.floor(huef)
        f = huef - i

        pv = value * (1 - sat)
        qv = value * (1 - sat * f)
        tv = value * (1 - sat * (1 - f))

        if (i == 0):
            R = value
            G = tv
            B = pv
        elif (i == 1):
            R = qv
            G = value
            B = pv
        elif (i == 2):
            R = pv
            G = value
            B = tv
        elif (i == 3):
            R = pv
            G = qv
            B = value
        elif (i == 4):
            R = tv
            G = pv
            B = value
        elif (i == 5):
            R = value
            G = pv
            B = qv
        elif (i == 6):
            R = value
            G = tv
            B = pv
        elif (i == -1):
            R = value
            G = pv
            B = qv
        else :
            R = value
            G = value
            B = value

    r = Clamp(math.floor(R*255))
    g = Clamp(math.floor(G*255))
    b = Clamp(math.floor(B*255))

    return (hex(r),hex(g),hex(b))

def Clamp(i) :
    if (i < 0) :
        return 0
    if (i > 255) :
        return 255
    return i

# TODO: tacking Amplitude and not AmplitudeFast, fix if needed

# parameters taken from BaseNoteFinder.cs
OctaveBinCount = 24
BIN_QTY = 12

# parameters taken from config file
LEDCount = 50
LightSiding = 1.0
SteadyBright = False    # never used?
LEDFloor = 0.1
LEDLimit = 1.0
SatuartionAmplifier = 1.6

# these are floating point values
NoteAmplitudes     = [0 for x in range(0, BIN_QTY)]    # amplitudes of each note
NoteAmplitudesFast = [0 for x in range(0, BIN_QTY)]    
NotePositions      = [0 for x in range(0, BIN_QTY)]    # location of notes in range [0,1]
NoteAmplitudes[0] = 1

# FINAL TEST
NoteAmplitudes     = [0.586363, 0.700599, 0.439384162, 0, 0, 0, 0, 0, 0, 0, 0, 0]
NoteAmplitudesFast = [0.586363, 0.700599, 0.439384162, 0, 0, 0, 0, 0, 0, 0, 0, 0] 
NotePositions      = [0.483611822, 0.261237949, 0.843279064, 0.9416283, 0.7759455, 0.6389774, 0.3373046, 0.5607608, 0.03857844, -4.16666651, -4.16666651, 0]
# expects ef00d7, ff3700, 00b349

AmplitudeSum = 0.0

# initiate values "using" inputs BaseNoteFinder.Notes[i].Position and BaseNoteFinder.Notes[i].AmplitudeFiltered
for i in range(0, BIN_QTY) :
    #NotePositions[i]  = random.random()        # BaseNoteFinder.Notes[i].Position is being replaced by random number, final range should be 0-1
    #NoteAmplitudes[i] = math.pow(random.randint(0,100), LightSiding) # BaseNoteFinder.Notes[i].AmplitudeFiltered is being replaced by a random number, no range constraints know
    #NoteAmplitudesFast = [0 for x in range(0, BIN_QTY)] # TODO: figure what kind of values I expect here
    AmplitudeSum += NoteAmplitudes[i]


# remove notes that are weaker than threshold
AmplitudeSumAdj = 0
for i in range(0, BIN_QTY) :
    NoteAmplitudes[i] -= LEDFloor * AmplitudeSum
    if (NoteAmplitudes[i] / AmplitudeSum < 0) :
        NoteAmplitudes[i] = 0
        NoteAmplitudesFast[i] = 0
    AmplitudeSumAdj += NoteAmplitudes[i]

AmplitudeSum = AmplitudeSumAdj


LEDColors = [-1.0 for x in range(0, LEDCount)]      # color range[0,1] of each LED in the chain
LEDAmplitudes = [-1.0 for x in range(0, LEDCount)]  # amplitude of each LED in the chain
LEDAmplitudesFast = [-1.0 for x in range(0, LEDCount)]  # amplitude of each LED in the chain
LEDsFilled = 0

# designate color and amplitude of each LED
for note in range(0, BIN_QTY) :
    LEDCountColor = (int)(NoteAmplitudes[note] / AmplitudeSum * LEDCount)
    for LED in range(0, LEDCountColor) :
        if (LEDsFilled < LEDCount) :    # second loop condition
            LEDColors[LEDsFilled] = NotePositions[note]
            LEDAmplitudes[LEDsFilled] = NoteAmplitudes[note]
            LEDAmplitudesFast[LEDsFilled] = NoteAmplitudesFast[note]
            LEDsFilled += 1

# if no LEDs are filled set the first to black
if (LEDsFilled == 0) :
    LEDColors[0] = 0
    LEDAmplitudes[0] = 0
    LEDAmplitudesFast[0] = 0
    LEDsFilled += 1

# fill undesignated LEDs with the last color and amplitude used
while(LEDsFilled < LEDCount) :
    LEDColors[LEDsFilled] = LEDColors[LEDsFilled - 1]
    LEDAmplitudes[LEDsFilled] = LEDAmplitudes[LEDsFilled - 1]
    LEDAmplitudesFast[LEDsFilled] = LEDAmplitudesFast[LEDsFilled - 1]
    LEDsFilled += 1



OutputDataDiscrete = [-1.0 for x in range(0, LEDCount)] # THIS IS THE OUTPUT

for LED in range(0, LEDCount) :
    Saturation = LEDAmplitudes[LED] * SatuartionAmplifier
    SaturationFast = LEDAmplitudesFast[LED] * SatuartionAmplifier

    OutSaturation = Saturation if SteadyBright else SaturationFast
    if (OutSaturation > 1) :
        OutSaturation = 1
    if (OutSaturation > LEDLimit) :
        OutSaturation = LEDLimit
    Color = CCtoHEX(LEDColors[LED], 1.0, OutSaturation)
    OutputDataDiscrete[LED] = Color

print(OutputDataDiscrete)
