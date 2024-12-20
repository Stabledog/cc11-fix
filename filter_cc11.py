import argparse
from cc11_fix.filter import list_ports, filter_midi

def run_filter():
    parser = argparse.ArgumentParser(description='Filter out CC11 messages from MIDI input.')
    subparsers = parser.add_subparsers(dest='command', required=True)

    # Subparser for the "run" command
    subparsers.add_parser('run', help='Run the MIDI filter')

    # Subparser for the "list-ports" command
    subparsers.add_parser('list-ports', help='List available MIDI ports')

    args = parser.parse_args()

    if args.command == 'run':
        filter_midi()
    elif args.command == 'list-ports':
        list_ports()

if __name__ == '__main__':
    run_filter()
