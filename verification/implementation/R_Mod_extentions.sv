class extentions ;

    mailbox  #(elec_layer_tr) elec_ag_Tx ;
    int_packet i_transaction ;
    mailbox #(int_packet) int_ag ;
    elec_layer_tr               E_transaction ;
    
    

  function new(mailbox #(int_packet) int_ag ,  mailbox  #(elec_layer_tr) elec_ag_Tx ); 
    this.int_ag = int_ag;
    this.elec_ag_Tx = elec_ag_Tx;
    E_transaction = new();
    this.SB_read='b0;          //default of data is zeros
    this.sel='b1;              //to put default commend
  endfunction

    /////*defind constant parts of code*/////
      parameter DLE=8'hfe, 
                STX=7'h02,                                   //we will concatinate it with last bit represent (command_response)
                ETX=8'h40,
                DATA_Symbols=16'h034e;                        //reviewing(rig 12) =>incase send commend to read the parameters of another router 

       //some parameters//
       parameter SB_width=24,reg_size=16;     //sb reg size in bits
      
       //defind interface with tran_type block.
       logic [SB_width-1:0] SB_read;

    /////*defind properties of trans type block*///// 
       //defind interface with FSM controller
       bit               sel;  //sel=1 in case (command) and sel=0 in case response.
       //defind interface with serializer
       logic  [6:0][7:0] R_trans_2_serializar;  //response frame
       logic  [3:0][7:0] C_trans_2_serializar;  //command frame
    /////*defind properties of deserializer block*///// 
       bit            read_write;
       logic   [7:0]  address;
       logic   [6:0]  len;
       logic   [15:0] crc;
       logic   [SB_width-1:0] cmd_rsp_data;

      /////*defind function new*/////
  /*function void DefaultValue();

  //this.SB_add='b1100;        // first location to read default
  this.SB_read='b0;          //default of data is zeros
  this.sel='b1;              //to put default commend
  endfunction:DefaultValue*/


  /*task SB_RIG;
  input  logic [23:0] SB_write;
  input  logic [7:0]  SB_add;
  input  bit          sb_en,W_R;   //W_R=1 in case (read) and =0 in case (write).

  logic [23:0] SB_mem[63:0];      //defind SB_mem
  if(sb_en)
      begin
       if(W_R)
        begin
          this.SB_read=SB_mem[SB_add];
        end
       else
         SB_mem[SB_add]=SB_write;
      end


endtask:SB_RIG*/


task trans_type;
   input  bit       tran_en,sel;
   this.sel=sel;

   
   ////$display("[wellooooooo]tran_en = %0d",tran_en);
   if(1)
      begin
        ////$display("[wellooooooo]this.sel = %0d",this.sel);
        if(this.sel) //case command 
        begin
          this.C_trans_2_serializar={>>{DATA_Symbols,STX,sel,DLE}};
          //$display("[wellooooooo]C_trans_2_serializar =%0h",this.C_trans_2_serializar);
        end
        else   //case response
        begin
          this.cmd_rsp_data=24'd340739;
          ////$display("[wellooooooo]cmd_rsp_data = %d",this.cmd_rsp_data);
          this.R_trans_2_serializar={>>{cmd_rsp_data,DATA_Symbols,STX,sel,DLE}};
           //$display("[welloooo] at trans_type task the value of this.R_trans_2_serializar %0h and the size=%0d",this.R_trans_2_serializar,$size(R_trans_2_serializar));    
        end
  
      end

endtask:trans_type


task generate_AT;


   logic [5:0][7:0]          R_trans_2_serializar;       //serial data response
   logic [2:0][7:0]          C_trans_2_serializar;       //serial data commmend
   bit   [15:0]              crc;
   bit   [reg_size-1:0]      R_rigister,rigister;
   bit   [7:0]               b_yte;
   bit                       O_rig_15;



   rigister=16'hffff;  //initial value
   if(this.sel)        //command
   begin
     C_trans_2_serializar=this.C_trans_2_serializar[3:1];
    // C_trans_2_serializar={8'hfe,8'h51,8'h80,8'h0a,8'h43,8'h85,8'h62,8'h05};  
     ////$display("[welloooo] at generate_AT task the value of this.C_trans_2_serializar %0h and the size=%0d",C_trans_2_serializar,$size(C_trans_2_serializar));
      for(int k=0;k<$size(C_trans_2_serializar);k++)
       begin
        b_yte=C_trans_2_serializar[k];
        //operation/
       for(int i=0;i<8;i++)
         begin
           O_rig_15=rigister[15];
           rigister[15]=O_rig_15^rigister[14]^b_yte[i];
           for(int j=14;j>=3;j--)
             begin
              rigister[j]= rigister[j-1];
             end
            rigister[2]=O_rig_15^rigister[1]^b_yte[i];
            rigister[1]=rigister[0]; 
            rigister[0]=O_rig_15^b_yte[i];
         end
        end
    //**flip the register before concatination 
      for(int i=0;i<16;i++)
      begin
         R_rigister[i]=rigister[15-i];
      end
    crc=R_rigister;
   end
   else         //response
    begin
      R_trans_2_serializar=this.R_trans_2_serializar[6:1];
      ////$display("[welloooo] at generate_AT task the value of this.R_trans_2_serializar %0h and the size=%0d",R_trans_2_serializar,$size(R_trans_2_serializar));    
      for(int k=0;k<$size(R_trans_2_serializar);k++)
       begin
        b_yte=R_trans_2_serializar[k];
        //operation/
       for(int i=0;i<8;i++)
         begin
           O_rig_15=rigister[15];
           rigister[15]=O_rig_15^rigister[14]^b_yte[i];
           for(int j=14;j>=3;j--)
             begin
              rigister[j]= rigister[j-1];
             end
            rigister[2]=O_rig_15^rigister[1]^b_yte[i];
            rigister[1]=rigister[0]; 
            rigister[0]=O_rig_15^b_yte[i];
         end
        
        end
    //**flip the register before concatination 
      for(int i=0;i<16;i++)
      begin
         R_rigister[i]=rigister[15-i];
      end
      crc=R_rigister;
      end

////$display("[welloooo] at generate_AT task the value of crc %0h and the size=%0d",crc,$size(crc));
    this.crc=crc;
    this.len=7'd3;
    this.address=8'd78;
    this.read_write=1'b0;

         
          //connect with score_board//
	  if(this.sel)
	  E_transaction.transaction_type=AT_cmd;
	  else
	  E_transaction.transaction_type=AT_rsp;
	  
	    E_transaction.phase='d3;
      E_transaction.crc_received = this.crc;
      E_transaction.read_write = this.read_write;
      E_transaction.address = this.address;
      E_transaction.len = this.len;
      E_transaction.cmd_rsp_data = this.cmd_rsp_data;
      elec_ag_Tx.put(E_transaction);  
      //$display ("E_transaction in phase 3 sent to scoreboard = %p",E_transaction);
      E_transaction = new();  

endtask

task  get_values ();
    //DefaultValue();
    i_transaction = new();


    int_ag.get(i_transaction);
    ////$display ("[wellooooooo]i_transaction = %0d",i_transaction.At_sel);
    ////$display ("[wellooooooo]i_transaction.tran_en = %0d",i_transaction.tran_en);
   if (i_transaction.gen_res==0)      //  genrate command only for phase 3 
      begin
    // for generate command 
        trans_type(.sel(i_transaction.At_sel),.tran_en(i_transaction.tran_en));
        generate_AT();
          
        
      end

      else if (i_transaction.gen_res==1)      //  genrate  response
        begin
      // // for generate command 
      //     trans_type(.sel(i_transaction.At_sel),.tran_en(i_transaction.tran_en));
      //     generate_AT();
  
          // for generate response 
            trans_type(.sel(i_transaction.At_sel),.tran_en(1));
            generate_AT();
            $stop;
          
            
        end

endtask



endclass:extentions

