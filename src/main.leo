program sesame.aleo {
    struct Organizer {
        authority: address,
        name_a: [u8; 32],
        name_b: [u8; 32],
    }

    struct Event {
        authority_ticket: address,
        authority_check_in: address,
        num_tickets_issued: u32,
        num_tickets_max: u32,
    }

    record Ticket {
        owner: address,
        event_id: u64,
        seat: u32,
        checked_in: bool,
    }

    mapping organizers: u32 => Organizer;

    mapping events: u64 => Event;

    
    // Register self as an organizer
    transition register_organizer(organizer_id: u32, name_a: [u8; 32], name_b: [u8; 32]) {
        return then finalize(organizer_id, self.caller, name_a, name_b);
    }

    finalize register_organizer(organizer_id: u32, caller: address, name_a: [u8; 32], name_b: [u8; 32]) {
        let organizer_exists: bool = Mapping::contains(organizers, organizer_id);

        // Organizer must not yet exist
        assert(!organizer_exists);

        // Update the organizer mapping
        let organizer_info_new: Organizer = Organizer {
            authority: caller,
            name_a,
            name_b,
        };

        Mapping::set(organizers, organizer_id, organizer_info_new);
    }

    // Update the authority for some organizer
    //TODO


    // Register a new event
    transition create_event(organizer_id: u32, event_id: u64, authority_ticket: address, authority_check_in: address, num_tickets_max: u32) {
        return then finalize(self.caller, organizer_id, event_id, authority_ticket, authority_check_in, num_tickets_max);
    }

    finalize create_event (caller: address, organizer_id: u32, event_id: u64, authority_ticket: address, authority_check_in: address, num_tickets_max: u32) {
        // The event_id >> 32 must match the organizer_id
        let organizer_from_event: u32 = (event_id >> 32u8) as u32;
        assert_eq(organizer_from_event, organizer_id);

        // The event must not yet exist
        let event_exists: bool = Mapping::contains(events, event_id);
        assert(!event_exists);

        // Organizer must be registered & authority must be the caller
        let organizer_info: Organizer = Mapping::get(organizers, organizer_id);
        assert_eq(organizer_info.authority, caller);

        // Update the events mapping
        let event_info_new: Event = Event {
            authority_ticket,
            authority_check_in,
            num_tickets_issued: 0u32,
            num_tickets_max,
        };

        Mapping::set(events, event_id, event_info_new);
    }

    // Update event authorities
    //TODO


    // Issue a ticket for some event
    transition ticket_issue(event_id: u64, seat: u32, issue_to: address) -> Ticket {
        return Ticket {
            owner: issue_to,
            event_id,
            seat,
            checked_in: false,
        } then finalize(self.caller, event_id);
    }

    finalize ticket_issue(caller: address, event_id: u64) {
        // Load the event in question
        let event_info: Event = Mapping::get(events, event_id);

        // Makes sure the caller is authorized to issue tickets for this event
        assert_eq(caller, event_info.authority_ticket);

        // Make sure more tickets can still be issued
        assert(event_info.num_tickets_issued < event_info.num_tickets_max);

        // Update the number of issued tickets
        let event_info_new: Event = Event {
            authority_ticket: event_info.authority_ticket,
            authority_check_in: event_info.authority_check_in,
            num_tickets_issued: event_info.num_tickets_issued.add(1u32),
            num_tickets_max: event_info.num_tickets_max,
        };

        Mapping::set(events, event_id, event_info_new);
    }


    transition ticket_check_in(ticket: Ticket) -> Ticket {
        //TODO how to actually do this in aleo...
        // should be signed by events ticket_check_in authority; but object is private belongs to atendee?
        // maybe issue some other record
        return Ticket {
            owner: ticket.owner,
            event_id: ticket.event_id,
            seat: ticket.seat,
            checked_in: true,
        } then finalize(self.caller, ticket.event_id);
    }

    finalize ticket_check_in(caller: address, event_id: u64) {
        let event_info: Event = Mapping::get(events, event_id);
    }
}
