# inform quartus that the clk port brings a 50MHz clock into our design so
    # that timing closure on our design can be analyzed
 
create_clock -name CLK -period "50MHz" [get_ports CLK]