program sesame.aleo;

struct Organizer:
    authority as address;
    name_a as [u8; 32u32];
    name_b as [u8; 32u32];

struct Event:
    authority_ticket as address;
    authority_check_in as address;
    num_tickets_issued as u32;
    num_tickets_max as u32;

record Ticket:
    owner as address.private;
    event_id as u64.private;
    seat as u32.private;
    checked_in as boolean.private;


mapping organizers:
	key as u32.public;
	value as Organizer.public;


mapping events:
	key as u64.public;
	value as Event.public;

function register_organizer:
    input r0 as u32.private;
    input r1 as [u8; 32u32].private;
    input r2 as [u8; 32u32].private;
    async register_organizer r0 self.caller r1 r2 into r3;
    output r3 as sesame.aleo/register_organizer.future;

finalize register_organizer:
    input r0 as u32.public;
    input r1 as address.public;
    input r2 as [u8; 32u32].public;
    input r3 as [u8; 32u32].public;
    contains organizers[r0] into r4;
    not r4 into r5;
    assert.eq r5 true;
    cast r1 r2 r3 into r6 as Organizer;
    set r6 into organizers[r0];


function create_event:
    input r0 as u32.private;
    input r1 as u64.private;
    input r2 as address.private;
    input r3 as address.private;
    input r4 as u32.private;
    async create_event self.caller r0 r1 r2 r3 r4 into r5;
    output r5 as sesame.aleo/create_event.future;

finalize create_event:
    input r0 as address.public;
    input r1 as u32.public;
    input r2 as u64.public;
    input r3 as address.public;
    input r4 as address.public;
    input r5 as u32.public;
    shr r2 32u8 into r6;
    cast r6 into r7 as u32;
    assert.eq r7 r1;
    contains events[r2] into r8;
    not r8 into r9;
    assert.eq r9 true;
    get organizers[r1] into r10;
    assert.eq r10.authority r0;
    cast r3 r4 0u32 r5 into r11 as Event;
    set r11 into events[r2];


function ticket_issue:
    input r0 as u64.private;
    input r1 as u32.private;
    input r2 as address.private;
    cast r2 r0 r1 false into r3 as Ticket.record;
    async ticket_issue self.caller r0 into r4;
    output r3 as Ticket.record;
    output r4 as sesame.aleo/ticket_issue.future;

finalize ticket_issue:
    input r0 as address.public;
    input r1 as u64.public;
    get events[r1] into r2;
    assert.eq r0 r2.authority_ticket;
    lt r2.num_tickets_issued r2.num_tickets_max into r3;
    assert.eq r3 true;
    add r2.num_tickets_issued 1u32 into r4;
    cast r2.authority_ticket r2.authority_check_in r4 r2.num_tickets_max into r5 as Event;
    set r5 into events[r1];


function ticket_check_in:
    input r0 as Ticket.record;
    cast r0.owner r0.event_id r0.seat true into r1 as Ticket.record;
    async ticket_check_in self.caller r0.event_id into r2;
    output r1 as Ticket.record;
    output r2 as sesame.aleo/ticket_check_in.future;

finalize ticket_check_in:
    input r0 as address.public;
    input r1 as u64.public;
    get events[r1] into r2;
