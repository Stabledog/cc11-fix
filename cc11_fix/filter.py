import mido
import re

def list_ports():
    print("Available input ports:")
    for name in mido.get_input_names():
        print(f"  {name}")

    print("\nAvailable output ports:")
    for name in mido.get_output_names():
        print(f"  {name}")

def find_input_port(pattern):
    for name in mido.get_input_names():
        if re.match(pattern, name):
            return name
    raise ValueError(f"No input port matching pattern '{pattern}' found.")

def find_output_port(pattern):
    for name in mido.get_output_names():
        if re.match(pattern, name):
            return name
    raise ValueError(f"No output port matching pattern '{pattern}' found.")

def filter_midi():
    input_port_pattern = r"KOMPLETE KONTROL (- )?\d+ \d+"
    output_port_pattern = r"midi-filtered-cc11.*"
    
    try:
        input_port_name = find_input_port(input_port_pattern)
        output_port_name = find_output_port(output_port_pattern)
        
        with mido.open_output(output_port_name) as midiout:
            with mido.open_input(input_port_name) as inport:
                for msg in inport:
                    if not (msg.type == 'control_change' and msg.control == 11):
                        midiout.send(msg)
    except (IOError, OSError, ValueError) as e:
        print(f"Error: {e}")
        list_ports()
