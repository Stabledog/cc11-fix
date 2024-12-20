import mido

def list_ports():
    print("Available input ports:")
    for name in mido.get_input_names():
        print(f"  {name}")

def filter_midi(input_port_name):
    output_port_name = 'midi-filtered-cc11'
    try:
        with mido.open_output(output_port_name) as midiout:
            with mido.open_input(input_port_name) as inport:
                for msg in inport:
                    if not (msg.type == 'control_change' and msg.control == 11):
                        midiout.send(msg)
    except (IOError, OSError) as e:
        print(f"Error: {e}")
        list_ports()
