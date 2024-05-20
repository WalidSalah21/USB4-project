class elec_ref_AI;

  elec_layer_tr elec_layer_inst;
  upper_layer_tr upper_layer_inst;

  mailbox #(elec_layer_tr) elec_S;
  mailbox #(elec_layer_tr) elec_G;
  mailbox #(elec_layer_tr) elec_to_upper;
  mailbox #(upper_layer_tr) upper_to_elec;

  function new(mailbox #(elec_layer_tr) elec_S, mailbox #(elec_layer_tr) elec_G, mailbox #(elec_layer_tr) elec_to_upper, mailbox #(upper_layer_tr) upper_to_elec);
    this.elec_S = elec_S;
    this.elec_G = elec_G;
    this.elec_to_upper = elec_to_upper;
    this.upper_to_elec = upper_to_elec;
  endfunction

  task run;
    forever begin
      fork : thread
        // Thread 1
        begin
          elec_layer_inst = new();

          elec_G.get(elec_layer_inst);
          // CONDITION TO BE ADDED HERE TO SAVE THE GEN SPEED TO BE USED (AS REQUESTED BY KARIM)
          // CONDTION WILL CHECK THE CMD_RSP_DATA TO SAVE THE GEN SPEED IN A LOCALLY CREATED VARIABLE
          case (elec_layer_inst.phase)

            2: begin
                // Assign sbtx to 1
                elec_layer_inst.sbtx = 1;

                // Put elec_layer_inst in elec_S mailbox
                elec_S.put(elec_layer_inst);

                // Create a new instance for elec_layer_inst
                elec_layer_inst = new;
            end


            3: begin
                
                elec_layer_inst.tr_os = tr;
                elec_layer_inst.transaction_type = AT_cmd;
                elec_layer_inst.address = 78;
                elec_layer_inst.len = 3;
                elec_layer_inst.read_write = 0;
                elec_layer_inst.crc_received = 0;
                CRC_generator(STX_cmd, {8'd78,7'd3,1'h0},3);
                elec_layer_inst.cmd_rsp_data = 0;

                elec_S.put(elec_layer_inst);

                elec_layer_inst = new();
                elec_G.get(elec_layer_inst);
                
                if (elec_layer_inst.tr_os == tr && elec_layer_inst.transaction_type == AT_cmd && elec_layer_inst.address == 78 && elec_layer_inst.len == 3 && elec_layer_inst.read_write == 0) 
                begin
                    elec_layer_inst.tr_os = tr;
                    elec_layer_inst.transaction_type = AT_rsp;
                    elec_layer_inst.address = 78;
                    elec_layer_inst.len = 3;
                    elec_layer_inst.read_write = 0;
                    elec_layer_inst.crc_received = 0;
                    elec_layer_inst.cmd_rsp_data = 24'h053303; 
                    CRC_generator(STX_rsp, {8'd78,7'd3,1'b0,24'h033305},6); 
                    
                    elec_S.put(elec_layer_inst);
                    elec_layer_inst = new();
                end
            end

            5: begin
                  $display("DATA OBTAINED from electrical layer");
                  $display("electrical_to_transport = %0D, phase = %0D",elec_layer_inst.electrical_to_transport, elec_layer_inst.phase);
                  elec_to_upper.put(elec_layer_inst);
               end
              

          endcase
        end
        // Thread 2
        begin
          forever
          begin
            elec_layer_inst = new();
            upper_layer_inst = new();
            upper_to_elec.get(upper_layer_inst);
            if (upper_layer_inst.phase == 5) begin
              elec_layer_inst.transport_to_electrical = upper_layer_inst.T_Data;
              elec_S.put(elec_layer_inst);
            end
          end
          
        end
      join_any
    end
  endtask

  /****************************
   * CRC TASK generated using AI 
   * data: 31/3/2024
   * works correctly for the given example in the standard
   * 
   * *********************************/

  // CRC CALCULATOR 
  task CRC_generator(input [7:0] STX, input [39:0] data_symbol, input [2:0] size );
    reg [15:0] crc;
    reg [47:0] data;
    integer i;
    bit crc_last;
    localparam POLY = 16'h8005;
    // Initialize CRC
    crc = 16'hFFFF;

    //!!!!!!!!!!!!!!!! PLEASEE NOTE: data_symbol's cmd_rsp_data mafrood ne3ks el input bytes (lel function input bas msh el elec_reference kolo) 3ashan terg3 tet3ks we teb2a least to most significant tanii (24'h033305 badal 24'h053303)
    //$display("data_symbol %b",data_symbol);
    data_symbol = data_symbol << 8*(6-size);
    // Concatenate STX and data_symbol
    data = {STX,data_symbol};
    //$display("data before: %b",data);
    data = {<<8{{>>{data}}}};
    //$display("data after: %b",data);
   
    
  for (i = 0; i < size*8; i = i + 1) begin
      crc_last = crc[15];
      for (int n = 15; n > 0; n = n - 1) begin
        if (POLY[n] == 1'b1) begin
          crc[n] = crc[n-1] ^ crc_last ^ data[i];
        end else begin
          crc[n] = crc[n-1];
          end
      end
      crc[0] = data[i] ^ crc_last;
    end
  
    
    // Flip CRC
    crc = {<<{crc}};

    // XOR with 0000h
    elec_layer_inst.crc_received = crc ^ 16'h0000;

    // Print the output
    //$display("CRC: %b", elec_layer_inst.crc_received);
    //$display("CRC: %h", elec_layer_inst.crc_received);
  endtask



endclass