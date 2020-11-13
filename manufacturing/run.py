from subprocess import call
from gpiozero import MotionSensor
pir = MotionSensor(4)

while True:
    pir.wait_for_motion()
    print("You moved")
    rc = call("./connection_attempt.bash")
    pir.wait_for_no_motion()