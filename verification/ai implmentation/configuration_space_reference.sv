
class ConfigurationSpacesModel;
    // Declare mailbox handles for communication with the stimulus generator and scoreboard
    mailbox #(config_transaction) stimulus_mailbox;    // For receiving transactions from the stimulus generator
    mailbox #(config_transaction) scoreboard_mailbox;  // For sending read requests to the verification environment
    // Declare mailbox handles for communication with the electrical layer and upper layer
    mailbox electrical_mailbox;  // For sending transactions to the electrical layer reference model
    mailbox upper_mailbox;      // For sending transactions to the upper layer reference model

    // Constructor
    function new(mailbox #(config_transaction) stimulus_mb, mailbox #(config_transaction) scoreboard_mb, mailbox electrical_mb, mailbox upper_mb);
        // Initialize mailboxes
        stimulus_mailbox = stimulus_mb;
        scoreboard_mailbox = scoreboard_mb;
        electrical_mailbox = electrical_mb;
        upper_mailbox = upper_mb;
        // Initialize any internal variables if necessary
    endfunction

    // Task to read from configuration space
    task read_config_space(input bit [7:0] address, output bit [31:0] data);
        // Declare request and response transactions
        config_transaction request;
        config_transaction response;

        // Construct request transaction
        request = new();
        request.c_read = 1'b1;
        request.c_write = 1'b0;
        request.c_address = address;
        request.c_data_out = 32'd0; // Set c_data_out to 'd0

        // Send read request to the scoreboard
        scoreboard_mailbox.put(request);
    	//$display("[Config Space Ref] Read request sent to the scoreboard \n %p", request);


        // Construct response transaction
        response = new();

        // Wait for response from the stimulus generator
        stimulus_mailbox.get(response);
    	//$display("[Config Space Ref] Read response received from the generator \n %p", response);

        data = response.c_data_in;
    endtask

    // Task to write to configuration space
    task write_config_space(input bit [7:0] address, input bit [31:0] data);
        config_transaction request;
        request = new();
        request.c_write = 1'b1;
        request.c_read = 1'b0;
        request.c_address = address;
        request.c_data_out = data;
        // Send write request to the stimulus generator
        stimulus_mailbox.put(request);
    endtask
    
    // Task to perform the specified sequence
    task run;
        bit lane_disable;
        bit [31:0] value;
        config_transaction stimulus_transaction;
        
        forever begin
            // Wait for a transaction to come from the stimulus generator
            stimulus_mailbox.get(stimulus_transaction);
            
            // Read the phase signal of the transaction
            if (stimulus_transaction.phase == 1) begin
                // Read from the configuration space
                read_config_space(18, value);
                
                // Check the returned value and keep calling read function until 32'h00200040 is returned
                while (value != 32'h00200040) begin
                    read_config_space(18, value);
                end
            end else if (stimulus_transaction.lane_disable == 1'b1) begin
                // Send signal to electrical layer reference model
                electrical_mailbox.put(1'b1);
                // Send signal to upper layer reference model
                upper_mailbox.put(1'b1);
            end
        end
    endtask


endclass

