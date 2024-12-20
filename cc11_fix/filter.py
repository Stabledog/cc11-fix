import mido
import rtmidi

def list_ports():
    print("Available input ports:")
    for name in mido.get_input_names():
        print(f"  {name}")

def filter_midi(input_port_name):
    virtual_output_port_name = 'midi-filtered-cc11'
    try:
        midiout = rtmidi.MidiOut()
        midiout.open_virtual_port(virtual_output_port_name)
        
        with mido.open_input(input_port_name) as inport:
            for msg in inport:
                if not (msg.type == 'control_change' and msg.control == 11):
                    midiout.send_message(msg.bytes())
    except (IOError, OSError) as e:
        print(f"Error: {e}")
        list_ports()
