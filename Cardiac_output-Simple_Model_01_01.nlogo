globals [                  ;; setting the globals for the model functioning:
  count-down               ;; timer for the cardiac driving function
  tve                      ;; the time varying elastance
  list-p                   ;; the list for turtles coordinates (pressure)
  list-v                   ;; the list for turtles coordinates (volume)
  HR-f                     ;; factor for 'balancing' heart rate and dt
  k                        ;; scalar  accountable for some extracardiac influence
  axis                     ;; coordinate system
  LV-PV-loop-color         ;; color of the pressure-volume diagram
 ]

to setup

  ca

  if (scenario = "Normal") ;; setting parameters for "Normal" scenario
  [
   set E_v 0.0059
   set E_ao 0.6913
   set V0_lv 0
   set Vd_lv 0
   set P0_lv 0.1203
   set V_AO 50
   set V_LV 130
   set V_V 1000
   set R_mt 0.0158
   set R_ao 0.018
   set R_sys 1.0889
   set E_es_lv 2.8798
   set Lambda_lv 0.033
   set Preload_Volume-Status "Normal"
   set Afterload_Vascular-Resistance-sys "Normal-VR"
   set Myocardial-Contractility "Normal-contractility"
   set Vascular-Elastance-sys "Normal"
   set Aortic-stenosis? false
   set Mitral-stenosis? false
   set Heart-Rate 70
   set LV-PV-loop-color 55
  ]

   if (scenario = "Test")
  [ set LV-PV-loop-color 15]

  set count-down 0                                       ;; initialising the timer and tve
  set tve 0

  system-dynamics-setup

                                                          ;; setting the lists to be used for turtles x-coordinates
  set list-p []
  set list-v []

  create-axis                                             ;; setting coordinates system

                                                          ;; seting parameters values for different "Test" scenarios
  if (scenario = "Test") and (Preload_Volume-Status = "Decreased-preload-25%")
  [set V_V 625
   set V_lv 50]

  if (scenario = "Test") and (Preload_Volume-Status = "Decreased-preload-50%")
  [set V_V 250
  set V_lv 35]

  if (scenario = "Test") and (Preload_Volume-Status = "Increased-preload")
  [set V_V 1375]

  if (scenario = "Test") and (Myocardial-Contractility = "Decreased-contractility")
  [set E_es_lv 1.4]

   if (scenario = "Test") and (Myocardial-Contractility = "Increased-contractility")
  [set E_es_lv 4.0]

   if (scenario = "Test") and (Afterload_Vascular-Resistance-sys = "Increased VR X 2.0")
  [set R_sys 2.2]

   if (scenario = "Test") and (Afterload_Vascular-Resistance-sys = "Increased VR X 1.5")
  [set R_sys 1.6]

   if (scenario = "Test") and (Afterload_Vascular-Resistance-sys = "Decreased VR x 1.5")
  [set R_sys 0.67]


   if (scenario = "Test") and (Vascular-Elastance-sys = "Increased-arterial El+50%")
  [set E_ao 1.05]

   if (scenario = "Test") and (Vascular-Elastance-sys = "Decreased-arterial El-50%")
  [set E_ao 0.35]

   if (scenario = "Test") and (Vascular-Elastance-sys = "Increased-venous El+50%")
  [set E_v 0.009]

   if (scenario = "Test") and (Vascular-Elastance-sys = "Decreased-venous El-25%")
  [set E_v 0.0045]

   if (scenario = "Test") and (Aortic-stenosis? = true)
  [set R_ao 0.036]


   if (scenario = "Test") and (Mitral-stenosis? = true)
  [set R_mt 0.032]

  set HR-f round (( 60 / Heart-rate) * 1000)                                    ;; setting HR-f

  set k (Heart-rate * 0.015)                                                    ;; setting the k-scalar

  reset-ticks
end

to create-axis                                                                  ;; creating coordinates system
  ask patches with [ pxcor = 0 ] [ set pcolor white ]
  ask patches with [ pycor = 0 ] [ set pcolor white ]

   ask patch -4 -4
  [ set plabel "0"
    set plabel-color white ]
  ask patch 50 190
  [ set plabel "Pressure mmHg"
    set plabel-color white
    ]
  ask patch 190 7
  [ set plabel "Volume ml"
    set plabel-color white
   ]

 ask patch -4 100
  [ set plabel "100"
    set plabel-color white
   ]

 ask patch -4 20
  [ set plabel "20"
    set plabel-color white
   ]

  ask patch -4 40
  [ set plabel "40"
    set plabel-color white
   ]

  ask patch -4 60
  [ set plabel "60"
    set plabel-color white
   ]

  ask patch -4 80
  [ set plabel "80"
    set plabel-color white
   ]

  ask patch -4 120
  [ set plabel "120"
    set plabel-color white
   ]

  ask patch -4 140
  [ set plabel "140"
    set plabel-color white
   ]

  ask patch -4 160
  [ set plabel "160"
    set plabel-color white
   ]

  ask patch -4 180
  [ set plabel "180"
    set plabel-color white
   ]

   ask patch 50 -7
  [ set plabel "50"
    set plabel-color white ]

   ask patch 100 -7
  [ set plabel "100"
    set plabel-color white ]

   ask patch 150 -7
  [ set plabel "150"
    set plabel-color white ]
end

to go

  set count-down count-down + 1                         ;; starting the timer which governs the cardiac driving function
  if count-down = HR-f
  [reset-count-down]

  activate                                              ;; activating the cardiac driving function

  system-dynamics-go
  system-dynamics-do-plot

  create-list-v                              ;; generating coordinates for turtles coordinates as lists
  create-list-p

  if ticks > 15000
  [ create-turtles 1 [                       ;; creating a turtle every iteration/tick
    set color LV-PV-loop-color               ;; and ploting it according to the coordinates
    set shape "circle"                       ;; as values in the respective lists
    set size 1.0
    set xcor (last list-v)
    set ycor (last list-p)
    ]
  ]

  if (Scenario = "Normal") and ticks > 20000  ;; a stop command once the model reaches 20000 ticks and scenario = "Normal"
  [export-view "Norma1.png"                   ;; exporting the 'normal' pressure-volume diagram to be imported for comparison
  stop]                                       ;; as needed

  tick
end

  to activate                                 ;; activation of the cardiac driving function and tve
  ifelse count-down <= 500
  [set tve e ^ (-80 * ( count-down * 0.001 - 0.27 ) ^ 2)]
  [set tve 0]
end

to reset-count-down                           ;; reseting the timer for a new cardiac cycle
  set count-down 0
end

to-report result-v                            ;; generating lists with turtles coordinates
  report V_lv
end

to-report result-p
  report P_lv
end

to  Compare-N-PV-loops                         ;; importing the 'normal' PV-diagram
  import-drawing "Norma1.png"
end

                                               ;; building up lists with turtles coordinates
to create-list-v
  if ticks > 15000
  [set list-v lput result-v list-v]
end

to create-list-p
  if ticks > 15000
  [set list-p lput result-p list-p]
end

to reset-test                                  ;; reseting initial condition in the "Test" mode = same parameters as in "Normal" Scenario
   set E_v 0.0059
   set E_ao 0.6913
   set V0_lv 0
   set Vd_lv 0
   set P0_lv 0.1203
   set V_AO 50
   set V_LV 130
   set V_V 1000
   set R_mt 0.0158
   set R_ao 0.018
   set R_sys 1.0889
   set E_es_lv 2.8798
   set Lambda_lv 0.033
   set Preload_Volume-Status "Normal"
   set Afterload_Vascular-Resistance-sys "Normal-VR"
   set Myocardial-Contractility "Normal-contractility"
   set Vascular-Elastance-sys "Normal"
   set Heart-Rate 70
   set Aortic-stenosis? false
   set Mitral-stenosis? false
end

to export-image                                 ;; exporting the world view to be used for comparison
  export-view user-new-file
end
@#$#@#$#@
GRAPHICS-WINDOW
444
33
771
361
-1
-1
1.48
1
10
1
1
1
0
1
1
1
-15
200
-15
200
0
0
1
ticks
30.0

BUTTON
28
24
91
57
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
110
25
173
58
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
26
94
349
351
Pressures and Volumes over time
NIL
mm Hg / milliliters
0.0
10.0
0.0
10.0
true
true
"" "if ticks > 2000 [ set-plot-x-range ticks - 2000 ticks ]"
PENS
"P_lv" 1.0 0 -16777216 true "" "plot P_lv ;* 0.88"
"V_LV" 1.0 0 -2674135 true "" "plot V_LV"
"P_ao" 1.0 0 -13840069 true "" "plot P_ao ;* 0.88"
"100" 1.0 0 -5987164 true "" "plotxy plot-x-max 100"

CHOOSER
205
23
343
68
Scenario
Scenario
"Normal" "Test"
0

BUTTON
601
372
771
405
Compare-w-N-PV-loop
Compare-N-PV-loops
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
630
449
744
482
Clear-image
clear-turtles
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
475
10
730
42
Left Ventricle Pressure - Volume Diagram
13
0.0
1

CHOOSER
26
372
211
417
Preload_Volume-Status
Preload_Volume-Status
"Normal" "Decreased-preload-25%" "Decreased-preload-50%" "Increased-preload"
0

CHOOSER
28
428
212
473
Afterload_Vascular-Resistance-sys
Afterload_Vascular-Resistance-sys
"Normal-VR" "Increased VR X 1.5" "Increased VR X 2.0" "Decreased VR x 1.5"
0

CHOOSER
215
371
399
416
Myocardial-Contractility
Myocardial-Contractility
"Normal-contractility" "Decreased-contractility" "Increased-contractility"
0

CHOOSER
217
427
399
472
Vascular-Elastance-sys
Vascular-Elastance-sys
"Normal" "Increased-arterial El+50%" "Decreased-arterial El-50%" "Increased-venous El+50%" "Decreased-venous El-25%"
0

MONITOR
357
119
436
164
SV_LV ml/beat
max list-v - min list-v
2
1
11

MONITOR
359
185
435
230
CO l/min
(max list-v - min list-v) * Heart-Rate / 1000
2
1
11

MONITOR
359
250
436
295
EF %
((max list-v - min list-v) / max list-v) * 1.1 * 100
0
1
11

BUTTON
360
34
433
67
Reset Test 
reset-test
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
438
369
570
402
Heart-Rate
Heart-Rate
60
90
70.0
10
1
NIL
HORIZONTAL

SWITCH
439
410
569
443
Aortic-stenosis?
Aortic-stenosis?
1
1
-1000

SWITCH
439
449
569
482
Mitral-stenosis?
Mitral-stenosis?
1
1
-1000

BUTTON
630
411
744
444
Export-image
export-image
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

NB: This is a System Dynamics Model. In order to run it you shoulld download and run it on your PC. If it does not work contact: viapascurta@yahoo.com

This is a minimal lumped parameter System Dynamics (SD) model of the cardio-vascular system with the focus on Cardiac Output (CO) and factors influencing CO. 

The model is trying to explain and visualize the influence of a number of factors (i.e. preload, afterload, myocardial contractility, heart rate, etc.) on CO.

The effect of varying different model parameters can be observed on the resulting pressures and volumes and pressure-volume diagram and ultimately on the left ventricle CO in normal and pathological conditions.

Primary beneficiaries of the model are supposed to be medical students and residents.


## HOW IT WORKS

This is a SD model consisting of three compartments: two passive one for arterial and venous parts of the circulation and an active compartment for the left ventricle.

The model dynamics is governed by ordinary differential equations (ODE) which describe the dynamics and relation between three stocks (Left Ventricle Volume, Arterial Segment and Venous Segments Volumes) and respective flows.

The pulsatile nature of the flow is conditioned by a driver function, which mimics the myocardial contractions and a Heaviside step function  that simulates valvular mechanism based on the ‘open on pressure, close on ﬂow' principle. 

By changing different parameters (i.e. volume status, vascular resistance, myocardial contractility, vascular elastance, etc.) one can observe the effect on stroke volume (SV), ejection fraction (EF) and cardiac output (CO). With every set of parameters respective pressures and volumes are plotted and a pressure-volume diagram is generated. This can help understanding the CO principles physiology influenced by separate factors or their combination.

The ODE are as follows:

1. For the Left Ventricle:
dV_LV/dt = (P_v - P_lv) * k / R_mt - (P_lv - P_ao) * k / R_ao

2. For the Arterial Segment (aorta):
dV_AO/dt = (P_lv - P_ao) * k / R_ao - (P_ao - P_v) / R_sys

3. For the Venous Segment:
dV_V/dt = (P_ao - P_v) / R_sys - (P_v - P_lv) * k / R_mt

where,
V_LV (ml) - left ventricle volume,
V_AO (ml) - arterial segment (aorta) volume,
V_V (ml) - venous segment volume,
P_v (mmHg) - pressure in the venous segment,
P_lv (mmHg) - pressure in the left ventricle,
P_ao (mmHg) - pressure in the aorta,
R_mt (mmHg*s*ml^-1) - mitral valve resistance,
R_ao (mmHg*s*ml^-1 ) - aortic valve resistance
R_sys (mmHg*s*ml^-1 ) - systemic vascular resistance,
k - a scalar used to account for some extracardiac regulatory influence.

Since this is a closed-loop model certain components of the equations repeat for different stocks.

The general concept of this model uses the analogous metrics between the electrical domain and ﬂuid dynamics, based on the Ohm's Law (I = U / R), 
where,
_I (Current A) is equivalent to flow rate (ml*s^−1); U (Voltage V) is equivalent to fluid pressure (mmHg) and R (Resistance Ohm) is equivalent to resistance of different segments of the circulation (mmHg*s*ml^−1), Q (Charge C) - Volume, V (ml) and C (Capacitance F) - Compliance, C (ml*mmHg^−1). Elastance is the reciprocal of Compliance (1 / C)._ 

Blood flow = P2 - P1 / R, where P1,2 are pressures in vicinity segments and R represents resistance to the flow at the respective segments junction

Pressures is calculated as the product of elastance (E mmHg*ml^−1) and volume (V ml):
Arterial (Aortic) pressure = E_ao * V_AO, where E_ao is aortic elastance
Venous pressure = E_v * V_V, where E_v is venous elastance

Left ventricle pressure is calculated as follows:

P_lv = tve * E_es_lv * (V_lv - Vd_lv) + (1 - tve) * P0_lv * (exp(Lambda_lv * (V_lv - V0_lv)) - 1)

where,
tve (dimensionless) - is the left ventricle time varying elastance,
E_es_lv (mmHg*ml^−1) - left ventricle end-systolic elastance,
V_lv (ml) - left ventricle volume,
Vd_lv (ml) - unstressed left ventricle volume, 
P0_lv (mmHg) -  zero-volume left ventricle pressure, 
Lambda_lv (ml^-1) - left ventricle lambda (the curvature of end-diastolic pressure-volume relationship (EDPVR) function/line),
V0_lv (ml) - zero-pressure left ventricle volume. 


The driver function concerning Time Varying Elastance (tve):

tve = e ^ (-80 * ( time - 0.27 ) ^ 2), where 'time' is the period of time of a cardiac cycle

Stroke volume (ml/beat):

SV = V_ed - V_es, where V_ed is the end-diastolic volume and V_es is the volume at the end of systole

Ejection fraction (%):

EF = V_ed - V_es / V_ed * 1.1 * 100, where "1.1" is a scalar used for consistency of physiological values for EF

Cardiac output (l/min):

CO = SV * Heart-rate / 1000, where division to 1000 is for conversion of milliliters to liters

With every tick calculations of variables concerning stocks and flows are performed and values for volumes and pressures are shown on the plot. SV, CO and EF are reported by respective monitors. Generated pressures and volumes for the left ventricle are used for setting coordinates for turtles which are accordingly placed on the world window creating the pressure-volume diagram.

The initial parameters for "Normal" scenario are as follows:

V_LV - 130 ml
V_AO - 50 ml
V_V  - 1000 ml
E_v  - 0.0059 mmHg*ml^−1
E_ao - 0.6913 mmHg*ml^−1
V0_lv - 0 ml
Vd_lv - 0 ml
P0_lv - 0.1203 mmHg
R_mt - 0.0158 mmHg*s*ml^-1
R_ao - 0.018 mmHg*s*ml^-1
R_sys - 1.0889 mmHg*s*ml^-1
E_es_lv - 2.8798 mmHg*ml^−1
Lambda_lv - 0.033 ml^-1
Heart-Rate 70 bpm

## HOW TO USE IT

(1) Setup: creates basic conditions for the model to run (i.e. erases data from previous runs, set parameter values typical for the chosen scenario, etc.). 

(2) Go: starts running the model with generation of new variables values as a result of calculations, performed every time-step. 

(3) Scenario chooser: select a scenario out of two options: "Normal" or "Test". Choosing the second option makes it is possible to change model parameters. This is recommended to be done before a new run. The scenario should be chosen before pressing “Setup” and “Go” buttons. 

(4) Reset Test: pressing this button in the "Test" mode/scenario will set all the parameters as for the "Normal" scenario not changing the scenario.

(5) Plot - represents a number of model variables over time ( red line - left ventricle volume (V_LV), black line - left ventricle pressure (P_lv), green line - pressure in the aorta (P_ao) and “100 ml/mmHg - line” of grey color) 

(6), (7) and (8) are monitors which report respective model variables: SV_LV ml/beat - left ventricle stroke volume, CO l/min - cardiac output, EF % - ejection fraction.  

(9) through (12) are choosers which allow to change some parameters of the model (e.g. preload/volemic status, afterload/vascular resistance, myocardial contractility, vascular elastance)

(13) is a slider for setting the heart rate in a range between 60 and 90 bpm

(14) and (15) are switches for adding to a "Test" scenario one is playing with such "aggravating" conditions as mild aortic or/and mitral stenosis.

(16) The window where Pressure-Volume diagram is being generated according to the selected parameter values. For the "Normal" scenario the diagram color will be green and for the "Test" scenarios it will be of red color. 

(17) Compare-w-N-PV-loop button - once pressed it will import a normal PV diagram to be compared with the actual diagram generated by the current "Test" run. To became active this button needs a full-time (i.e. 20000 ticks) "Normal" scenario run before a "Test" scenario run. It is recommended to do this one time at the beginning of the play-with-the-model session.

(18) Export-image button will export the view of the window with PV diagrams as a ".png" file. The .png extension should be specified/written in while saving the file. 

(19) Clear-image button will erase the actual PV diagram not affecting the imported diagram by (17) button. This window will be completely cleared-up by pressing "Setup" button.  


## THINGS TO NOTICE

This is a lumped parameter cardiovascular model that is capable of representing important properties and dynamics of the cardiovascular system in a healthy state as well as a range of pathological conditions. The model is a compromise between physiological accuracy and computational expense.

The time-varying elastance is a central part of the model. The time-varying elastance represents the activation of the myocardial muscle. In both the model and physiological context, the time-varying elastance is a key component of much of the cardiovascular dynamics, in value, timing and shape. This function is what drives the model.   

Limitations:

* The lumped parameter nature of the model gives rise to some limitations on the accuracy and detail of the physiological dynamics that the model can capture. For example, the dicrotic notch in the aortic pressure waveform is not captured by the model, due to the lack of reﬂected pressure waveforms in the model. However, the model does capture all the major dynamics of the cardiovascular system that are important in managing and controlling cardiac dysfunction in a clinical setting.
* This model does not account for inter-ventricular interaction
* It does not include lung ventilation influence
* According to the model ("Normal" scenario) the minimal value for the pressure in the left ventricle (LVEDP) is close to "0" while a normal value ranges between 4 and 12 mmHg.
* The valves are modelled based on an ‘open on pressure, close on ﬂow’ formulation, and inherently do not allow ﬂow in the reverse direction. Therefore dysfunctions such as mitral and aortic regurgitation, which are the insufﬁcient valvular functions allowing back ﬂow, cannot be captured without modiﬁcation to the model.
* The biggest simpliﬁcation is the representation of large sections of the circulation through discrete model chambers. These chambers appear, and are named, in the model as a single section, but physiologically and anatomically represent a much wider context. For example the aortic chamber represents the entire series of elastic arteries of the systemic circulation. Therefore, the associated model parameters are averages or averaged representations of this large section of the circulation.
* Inertial effects, are not included in the simulation. However, the effect of inertia can generally be regarded as insigniﬁcant, which is typically the case in many models.
* Some of the initial parameters for "Normal" scenario differ from physiological values. Their value along with some scalars used in the model are selected to produce a model output close to a ‘physiological’ one.
* The main parameters of the model, namely, elastance (E) and resistance (R) are assumed to be constant except for the ventricular elastances which vary in time. This assumption is a simpliﬁcation of the real physiology. However, it does not introduce much error compared to measurement errors, and vastly reduces the complexity and computational cost for solving the model. Hence, the assumption of constant parameter values is common among lumped parameter models 


## THINGS TO TRY

Run the model with "Normal" scenario. Then select "Test" scenario and observe the influence of changing factors that influence the CO (by bottom choosers and switches for preload, afterload, contractility) one by one and in combination.

Try to simulate different pathological conditions by changing respective model parameters (e.g. Arterial Hypertension in a patient with Heart Failure by selecting "Increased Vascular Resistance” (x 1.5 or x 2.0) in combination with "Decreased Myocardial Contractility").

Which factors will primarily influence the EF?

Which factors have the highest impact on CO? Which combination will result in the lowest CO? 

Export few different PV diagrams and try to analyze them in terms of O2 myocardial requirements (as PV area) in respective pathological condition.


## EXTENDING THE MODEL

The good agreement of the results with clinical data shows the potential of this modeling approach for predicting trends in the CVS. With future development of the model, more subtle trends in the CVS hemodynamics can be simulated.

## NETLOGO FEATURES

The model was built with NetLogo SDM and represent combination of SDM and 'main' NetLogo possibilities. The PV diagram is based on turtles with their coordinates generated by SDM calculations.

## RELATED MODELS

* Ventricle_three_vessel_loop Model (Jsim): http://www.physiome.org/jsim/models/webmodel/NSR/Ventricle_three_vessel_loop/

* Ventricle_Driven_Two_Vessel Model (Jsim): http://www.physiome.org/jsim/models/webmodel/NSR/Ventricle_Driven_Two_Vessel/


## CREDITS AND REFERENCES

This simple abstract model was developed by Victor Iapascurta, MD. At time of development he was in the Department of Anesthesia and Intensive Care at University of Medicine and Pharmacy in Chisinau, Moldova / ICU at City Emergency Hospital in Chisinau. Please email any questions or comments to viapascurta@yahoo.com

The model was created in NetLogo 6.0.3, Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.  

Re. concerning medical aspects:

* Bram W. Smith et al., A Minimal Cardiovascular System Haemodynamic Model for Rapid Diagnostic Assistance, Copyright © 2003 IFAC 

* Bram W. Smith et al., Experimentally Verified Minimal Cardiovascular System Model For Rapid Diagnostic Assistance, Control Engineering Practice, September 2005 DOI:	10.1016/j.conengprac.2004.10.014

* Bram W. Smith (2004), Minimal Haemodynamic Modelling of the Heart and Circulation for Clinical Application, PhD thesis, Canterbury University 

* Keith R. Walley, Left ventricular function: time-varying elastance and left ventricular aortic coupling,  Critical Care (2016) 20:270 DOI 10.1186/s13054-016-1439-6
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
0.001
    org.nlogo.sdm.gui.AggregateDrawing 37
        org.nlogo.sdm.gui.StockFigure "attributes" "attributes" 1 "FillColor" "Color" 225 225 182 446 244 60 40
            org.nlogo.sdm.gui.WrappedStock "V_LV" "130\n;ifelse-value (Scenario = \"Normal\")\n;[130]\n;[50]" 1
        org.nlogo.sdm.gui.StockFigure "attributes" "attributes" 1 "FillColor" "Color" 225 225 182 284 383 60 40
            org.nlogo.sdm.gui.WrappedStock "V_V" "1000" 0
        org.nlogo.sdm.gui.StockFigure "attributes" "attributes" 1 "FillColor" "Color" 225 225 182 600 385 60 40
            org.nlogo.sdm.gui.WrappedStock "V_AO" "50" 1
        org.nlogo.sdm.gui.RateConnection 3 350 371 393 333 437 296 NULL NULL 0 0 0
            org.jhotdraw.standard.ChopBoxConnector REF 3
            org.jhotdraw.standard.ChopBoxConnector REF 1
            org.nlogo.sdm.gui.WrappedRate "ifelse-value (P_v > P_lv)\n[(P_v - P_lv) * k / R_mt ]\n[0]" "F_v" REF 4 REF 2 0
        org.nlogo.sdm.gui.RateConnection 3 511 296 553 334 595 373 NULL NULL 0 0 0
            org.jhotdraw.standard.ChopBoxConnector REF 1
            org.jhotdraw.standard.ChopBoxConnector REF 5
            org.nlogo.sdm.gui.WrappedRate "ifelse-value (P_lv > P_ao)\n[((P_lv - P_ao) * k) / R_ao]\n[0]" "F_a" REF 2 REF 6 0
        org.nlogo.sdm.gui.RateConnection 3 588 404 472 403 356 403 NULL NULL 0 0 0
            org.jhotdraw.standard.ChopBoxConnector REF 5
            org.jhotdraw.standard.ChopBoxConnector REF 3
            org.nlogo.sdm.gui.WrappedRate "(P_ao - P_v) / R_sys" "F_sys" REF 6 REF 4 0
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 188 438 50 50
            org.nlogo.sdm.gui.WrappedConverter "E_V * V_v" "P_v"
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 158 298 50 50
            org.nlogo.sdm.gui.WrappedConverter "0.0059" "E_v"
        org.nlogo.sdm.gui.BindingConnection 2 272 427 228 453 NULL NULL 0 0 0
            org.jhotdraw.standard.ChopBoxConnector REF 3
            org.jhotdraw.contrib.ChopDiamondConnector REF 19
        org.nlogo.sdm.gui.BindingConnection 2 187 343 208 442 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 21
            org.jhotdraw.contrib.ChopDiamondConnector REF 19
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 702 435 50 50
            org.nlogo.sdm.gui.WrappedConverter "E_ao * V_AO" "P_ao"
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 783 365 50 50
            org.nlogo.sdm.gui.WrappedConverter "0.6913" "E_ao"
        org.nlogo.sdm.gui.BindingConnection 2 794 401 740 448 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 31
            org.jhotdraw.contrib.ChopDiamondConnector REF 29
        org.nlogo.sdm.gui.BindingConnection 2 672 428 711 450 NULL NULL 0 0 0
            org.jhotdraw.standard.ChopBoxConnector REF 5
            org.jhotdraw.contrib.ChopDiamondConnector REF 29
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 450 154 50 50
            org.nlogo.sdm.gui.WrappedConverter "tve * E_es_lv * (V_lv - Vd_lv) + (1 - tve) * P0_lv * (exp(Lambda_lv * (V_lv - V0_lv)) - 1)" "P_lv"
        org.nlogo.sdm.gui.BindingConnection 2 466 195 393 333 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 39
            org.nlogo.sdm.gui.ChopRateConnector REF 7
        org.nlogo.sdm.gui.BindingConnection 2 227 452 393 333 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 19
            org.nlogo.sdm.gui.ChopRateConnector REF 7
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 280 203 50 50
            org.nlogo.sdm.gui.WrappedConverter "0.0158" "R_mt"
        org.nlogo.sdm.gui.BindingConnection 2 316 241 393 333 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 47
            org.nlogo.sdm.gui.ChopRateConnector REF 7
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 636 207 50 50
            org.nlogo.sdm.gui.WrappedConverter "0.018" "R_ao"
        org.nlogo.sdm.gui.BindingConnection 2 483 195 553 334 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 39
            org.nlogo.sdm.gui.ChopRateConnector REF 11
        org.nlogo.sdm.gui.BindingConnection 2 712 449 553 334 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 29
            org.nlogo.sdm.gui.ChopRateConnector REF 11
        org.nlogo.sdm.gui.BindingConnection 2 648 244 553 334 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 52
            org.nlogo.sdm.gui.ChopRateConnector REF 11
        org.nlogo.sdm.gui.BindingConnection 2 706 455 472 403 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 29
            org.nlogo.sdm.gui.ChopRateConnector REF 15
        org.nlogo.sdm.gui.BindingConnection 2 233 458 472 403 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 19
            org.nlogo.sdm.gui.ChopRateConnector REF 15
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 451 462 50 50
            org.nlogo.sdm.gui.WrappedConverter "1.0889" "R_sys"
        org.nlogo.sdm.gui.BindingConnection 2 474 463 472 403 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 69
            org.nlogo.sdm.gui.ChopRateConnector REF 15
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 402 102 50 50
            org.nlogo.sdm.gui.WrappedConverter "0" "V0_lv"
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 444 65 50 50
            org.nlogo.sdm.gui.WrappedConverter "2.8798" "E_es_lv"
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 520 145 50 50
            org.nlogo.sdm.gui.WrappedConverter "0" "Vd_lv"
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 481 98 50 50
            org.nlogo.sdm.gui.WrappedConverter "0.1203" "P0_lv"
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 543 93 50 50
            org.nlogo.sdm.gui.WrappedConverter "0.033" "Lambda_lv"
        org.nlogo.sdm.gui.BindingConnection 2 439 140 463 166 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 74
            org.jhotdraw.contrib.ChopDiamondConnector REF 39
        org.nlogo.sdm.gui.BindingConnection 2 470 113 473 155 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 76
            org.jhotdraw.contrib.ChopDiamondConnector REF 39
        org.nlogo.sdm.gui.BindingConnection 2 497 139 483 162 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 80
            org.jhotdraw.contrib.ChopDiamondConnector REF 39
        org.nlogo.sdm.gui.BindingConnection 2 522 172 497 176 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 78
            org.jhotdraw.contrib.ChopDiamondConnector REF 39
        org.nlogo.sdm.gui.BindingConnection 2 552 127 490 169 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 82
            org.jhotdraw.contrib.ChopDiamondConnector REF 39
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
