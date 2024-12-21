import mido
import re
import sys

def list_ports():
    """
    Lists available MIDI input and output ports.
    """
    print("Available input ports:")
    for name in mido.get_input_names():
        print(f"  {name}")

    print("\nAvailable output ports:")
    for name in mido.get_output_names():
        print(f"  {name}")

def find_input_port(pattern):
    """
    Finds an input port matching the given pattern.
    
    Args:
        pattern (str): The regex pattern to match the input port name.
    
    Returns:
        str: The name of the matching input port.
    
    Raises:
        ValueError: If no matching input port is found.
    """
    for name in mido.get_input_names():
        if re.match(pattern, name):
            return name
    raise ValueError(f"No input port matching pattern '{pattern}' found.")

def find_output_port(pattern):
    """
    Finds an output port matching the given pattern.
    
    Args:
        pattern (str): The regex pattern to match the output port name.
    
    Returns:
        str: The name of the matching output port.
    
    Raises:
        ValueError: If no matching output port is found.
    """
    for name in mido.get_output_names():
        if re.match(pattern, name):
            return name
    raise ValueError(f"No output port matching pattern '{pattern}' found.")

def filter_midi():
    """
    Filters MIDI messages from the input port and sends them to the output port,
    excluding control change messages with control number 11.
    
    The input and output ports are matched using predefined regex patterns.
    
    Raises:
        IOError, OSError, ValueError: If there is an error opening the ports or
                                      if the ports do not match the patterns.
    """
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
                        sys.stdout.write('.')
    except (IOError, OSError, ValueError) as e:
        print(f"Error: {e}")
