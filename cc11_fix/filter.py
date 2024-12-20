import mido

def list_ports():
    print("Available input ports:")
    for name in mido.get_input_names():
        print(f"  {name}")
    print("\nAvailable output ports:")
    for name in mido.get_output_names():
        print(f"  {name}")

def filter_midi(input_port_name, output_port_name):
    try:
        with mido.open_input(input_port_name) as inport, mido.open_output(output_port_name) as outport:
            for msg in inport:
                if not (msg.type == 'control_change' and msg.control == 11):
                    outport.send(msg)
    except (IOError, OSError) as e:
        print(f"Error: {e}")
        list_ports()

