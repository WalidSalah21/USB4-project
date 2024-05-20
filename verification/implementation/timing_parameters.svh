	
	parameter [63:0] tDisconnectTx 		=  50 	* 10 ** 12;
	parameter [63:0] tDisconnectTx_min	=  14	* 10 ** 9;
	parameter [63:0] tDisconnectTx_max 	=  1000 * 10 ** 9;
	parameter [63:0] tConnectRx 		=  25 	* 10 ** 9;
	parameter [63:0] tCmdResponse 		=  50 	* 10 ** 12;
	parameter [63:0] tDisabled 			=  10 	* 10 ** 12;
	parameter [63:0] tTrainingError  	=  500 	* 10 ** 9;
	parameter [63:0] tGen4TS1 			=  400 	* 10 ** 12;
	parameter [63:0] tGen4TS2 			=  200 	* 10 ** 12;
	parameter [63:0] tSSCActivated 		=  2 	* 10 ** 9;


	logic [63:0] sbrx_raised_time;
	logic [63:0] sbtx_raised_time;
	logic [63:0] lane_0_tTrainingError_time;
	logic [63:0] lane_1_tTrainingError_time;
	logic [63:0] lane_0_tGen4TS1;
	logic [63:0] lane_1_tGen4TS1;
	logic [63:0] lane_0_tGen4TS2;
	logic [63:0] lane_1_tGen4TS2;



	//To be moved to another file later
	logic host_device; // 0: Host, 1: Device	