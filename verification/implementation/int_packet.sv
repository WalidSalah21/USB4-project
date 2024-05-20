class int_packet;
    
   // ouputs
   bit tran_en;                   // enable of  trans_type
  // bit deser_en;              // enable of deserializer
   bit mem_en;                   // enable of  mem_config
   bit At_sel ;              // choose the type of  AT  command or response "0 for command , 1 for response"
   
   
   // to side band 
   bit         sb_en    ;               // enable of  sideband register
   bit         read_write ;         // read or write from sideband register (0->read, 1->write)
   bit [23:0] sb_data_in ;      // data from of from 
   bit [7:0] sb_add ;         // adress  
   //bit mem_gen ;              // 0 to make sb as mem  , 1 to make sb as gen 
   bit gen_res ;              // 0 for not generate responce , 1 for generate responce
   
endclass //
