import argparse
from cc11_fix.filter import list_ports, filter_midi

def main():
    parser = argparse.ArgumentParser(description='Filter out CC11 messages from MIDI input.')
    subparsers = parser.add_subparsers(dest='command', required=True)

    # Subparser for the "run" command
    run_parser = subparsers.add_parser('run', help='Run the MIDI filter')
    run_parser.add_argument('input_port', help='Name of the MIDI input port')

    # Subparser for the "list-ports" command
    list_ports_parser = subparsers.add_parser('list-ports', help='List available MIDI ports')

    args = parser.parse_args()

    if args.command == 'run':
        filter_midi(args.input_port)
    elif args.command == 'list-ports':
        list_ports()

if __name__ == '__main__':
    main()
