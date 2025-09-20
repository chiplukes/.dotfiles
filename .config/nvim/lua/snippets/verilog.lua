--[[
Verilog/SystemVerilog Snippets for LuaSnip
Comprehensive collection for digital design and verification
Includes modules, testbenches, assertions, and common patterns
--]]

local ls = require('luasnip')
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local fmt = require('luasnip.extras.fmt').fmt
local rep = require('luasnip.extras').rep

-- Utility functions
local function get_module_name()
  local filename = vim.fn.expand('%:t:r')
  return filename
end

local function get_current_date()
  return os.date('%Y-%m-%d')
end

local function get_author()
  return vim.fn.system('git config user.name'):gsub('\n', '') or 'Designer Name'
end

return {
  -- =============================================================================
  -- Module Templates
  -- =============================================================================
  
  -- Basic module template with header
  s('module', fmt([[
//============================================================================
// {module_name}.v
//
// {description}
//
// Author: {author}
// Date: {date}
//============================================================================

module {module_name} #(
    parameter {param_name} = {param_value}
) (
    // Clock and Reset
    input  wire clk,
    input  wire rst_n,
    
    // {interface_description}
    {ports}
    
    {body}
);

// Internal signals
{internal_signals}

// Module logic
{logic}

endmodule
]], {
    module_name = f(get_module_name),
    description = i(1, 'Module description'),
    author = f(get_author),
    date = f(get_current_date),
    param_name = i(2, 'DATA_WIDTH'),
    param_value = i(3, '8'),
    interface_description = i(4, 'Data Interface'),
    ports = i(5, 'input  wire [DATA_WIDTH-1:0] data_in,\n    output reg  [DATA_WIDTH-1:0] data_out'),
    internal_signals = i(6, 'reg [DATA_WIDTH-1:0] internal_reg;'),
    logic = i(0, '// TODO: Implement module logic'),
  })),

  -- Testbench template
  s('testbench', fmt([[
//============================================================================
// {tb_name}_tb.v
//
// Testbench for {module_name}
//
// Author: {author}
// Date: {date}
//============================================================================

`timescale 1ns/1ps

module {tb_name}_tb;

// Parameters
parameter CLK_PERIOD = 10; // 100MHz
parameter {param_name} = {param_value};

// DUT signals
reg clk;
reg rst_n;
{test_signals}

// DUT instantiation
{module_name} #(
    .{param_name}({param_name})
) dut (
    .clk(clk),
    .rst_n(rst_n),
    {port_connections}
);

// Clock generation
initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end

// Reset generation
initial begin
    rst_n = 0;
    repeat(5) @(posedge clk);
    rst_n = 1;
end

// Test sequence
initial begin
    $dumpfile("{module_name}_tb.vcd");
    $dumpvars(0, {tb_name}_tb);
    
    // Wait for reset deassertion
    @(posedge rst_n);
    @(posedge clk);
    
    // Test cases
    {test_cases}
    
    // Finish simulation
    #1000;
    $display("Test completed successfully!");
    $finish;
end

{additional_blocks}

endmodule
]], {
    tb_name = f(get_module_name),
    module_name = i(1, 'module_under_test'),
    author = f(get_author),
    date = f(get_current_date),
    param_name = i(2, 'DATA_WIDTH'),
    param_value = i(3, '8'),
    test_signals = i(4, 'reg  [DATA_WIDTH-1:0] test_data;\nwire [DATA_WIDTH-1:0] result;'),
    port_connections = i(5, '.data_in(test_data),\n    .data_out(result)'),
    test_cases = i(6, 'test_data = 8\'hAA;\n    @(posedge clk);\n    $display("Input: %h, Output: %h", test_data, result);'),
    additional_blocks = i(0),
  })),

  -- =============================================================================
  -- Common Logic Patterns
  -- =============================================================================
  
  -- Always block for combinational logic
  s('always_comb', fmt([[
always_comb begin
    {logic}
end
]], {
    logic = i(1, '// Combinational logic here'),
  })),

  -- Always block for sequential logic
  s('always_ff', fmt([[
always_ff @(posedge clk{reset_edge}) begin
    if ({reset_condition}) begin
        {reset_logic}
    end else begin
        {sequential_logic}
    end
end
]], {
    reset_edge = c(1, { t(''), t(' or negedge rst_n') }),
    reset_condition = c(2, { t('!rst_n'), t('rst') }),
    reset_logic = i(3, '// Reset logic'),
    sequential_logic = i(0, '// Sequential logic'),
  })),

  -- State machine template
  s('fsm', fmt([[
// State encoding
typedef enum logic [{state_width}:0] {{
    {states}
}} state_t;

state_t current_state, next_state;

// State register
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        current_state <= {reset_state};
    end else begin
        current_state <= next_state;
    end
end

// Next state logic
always_comb begin
    next_state = current_state; // Default assignment
    
    case (current_state)
        {state_cases}
        
        default: next_state = {reset_state};
    endcase
end

// Output logic
always_comb begin
    // Default outputs
    {default_outputs}
    
    case (current_state)
        {output_cases}
    endcase
end
]], {
    state_width = i(1, '1'),
    states = i(2, 'IDLE = 2\'b00,\n    ACTIVE = 2\'b01,\n    DONE = 2\'b10'),
    reset_state = i(3, 'IDLE'),
    state_cases = i(4, 'IDLE: begin\n            if (start) next_state = ACTIVE;\n        end\n        \n        ACTIVE: begin\n            if (complete) next_state = DONE;\n        end\n        \n        DONE: begin\n            next_state = IDLE;\n        end'),
    default_outputs = i(5, 'output_ready = 1\'b0;\n    output_valid = 1\'b0;'),
    output_cases = i(0, 'IDLE: output_ready = 1\'b1;\n        DONE: output_valid = 1\'b1;'),
  })),

  -- =============================================================================
  -- Interface and Protocol Patterns
  -- =============================================================================
  
  -- AXI4-Stream interface
  s('axis', fmt([[
// AXI4-Stream {direction} interface
{axis_signals}

// AXI4-Stream logic
{axis_logic}
]], {
    direction = c(1, { t('Master'), t('Slave') }),
    axis_signals = i(2, 'input  wire                    s_axis_tready,\noutput reg                     s_axis_tvalid,\noutput reg  [DATA_WIDTH-1:0]   s_axis_tdata,\noutput reg                     s_axis_tlast'),
    axis_logic = i(0, 'always_ff @(posedge clk) begin\n    if (s_axis_tready && s_axis_tvalid) begin\n        // Transfer logic\n    end\nend'),
  })),

  -- FIFO interface
  s('fifo', fmt([[
// FIFO interface
input  wire                  wr_en,
input  wire [DATA_WIDTH-1:0] wr_data,
output wire                  full,

input  wire                  rd_en,
output wire [DATA_WIDTH-1:0] rd_data,
output wire                  empty,

output wire [ADDR_WIDTH:0]   count
]], {})),

  -- =============================================================================
  -- Verification Constructs
  -- =============================================================================
  
  -- SystemVerilog assertions
  s('assert', fmt([[
// Assertion: {description}
{assertion_name}: assert property (
    @(posedge clk) disable iff (!rst_n)
    {property}
) else $error("{error_message}");
]], {
    description = i(1, 'Property description'),
    assertion_name = i(2, 'assertion_property'),
    property = i(3, 'signal_a |-> ##1 signal_b'),
    error_message = i(0, 'Assertion failed'),
  })),

  -- Coverage group
  s('covergroup', fmt([[
covergroup {cg_name} @(posedge clk);
    // Cover points
    {cover_point}: coverpoint {signal} {{
        bins low  = {{[0:31]}};
        bins mid  = {{[32:95]}};
        bins high = {{[96:127]}};
    }}
    
    // Cross coverage
    {cross_name}: cross {signal1}, {signal2};
endgroup

{cg_name} {instance_name} = new();
]], {
    cg_name = i(1, 'signal_cg'),
    cover_point = i(2, 'signal_cp'),
    signal = i(3, 'data_signal'),
    cross_name = i(4, 'signal_cross'),
    signal1 = i(5, 'signal_a'),
    signal2 = i(6, 'signal_b'),
    instance_name = i(0, 'cg_inst'),
  })),

  -- =============================================================================
  -- Common Code Snippets
  -- =============================================================================
  
  -- Generate block
  s('generate', fmt([[
generate
    for (genvar {var} = 0; {var} < {limit}; {var}++) begin : {label}
        {body}
    end
endgenerate
]], {
    var = i(1, 'i'),
    limit = i(2, 'NUM_INSTANCES'),
    label = i(3, 'gen_instances'),
    body = i(0, '// Generated logic here'),
  })),

  -- Initial block for simulation
  s('initial', fmt([[
initial begin
    {body}
end
]], {
    body = i(0, '// Initialization code'),
  })),

  -- Task definition
  s('task', fmt([[
task {task_name}({parameters});
    {body}
endtask
]], {
    task_name = i(1, 'my_task'),
    parameters = i(2, 'input logic [7:0] data'),
    body = i(0, '// Task implementation'),
  })),

  -- Function definition  
  s('function', fmt([[
function {return_type} {func_name}({parameters});
    {body}
    return {return_value};
endfunction
]], {
    return_type = i(1, 'logic [7:0]'),
    func_name = i(2, 'my_function'),
    parameters = i(3, 'input logic [7:0] data'),
    body = i(4, '// Function logic'),
    return_value = i(0, 'result'),
  })),

  -- =============================================================================
  -- Memory and Storage
  -- =============================================================================
  
  -- RAM template
  s('ram', fmt([[
// {ram_type} RAM - {data_width} bits x {depth} words
reg [{data_width}-1:0] memory [0:{depth}-1];

// Write operation
always_ff @(posedge clk) begin
    if (we) begin
        memory[wr_addr] <= wr_data;
    end
end

// Read operation  
{read_logic}
]], {
    ram_type = c(1, { t('Single Port'), t('Dual Port'), t('Simple Dual Port') }),
    data_width = i(2, 'DATA_WIDTH'),
    depth = i(3, 'DEPTH'),
    read_logic = c(4, {
      fmt('assign rd_data = memory[rd_addr];', {}),
      fmt([[always_ff @(posedge clk) begin
    rd_data <= memory[rd_addr];
end]], {}),
    }),
  })),

  -- Register file
  s('regfile', fmt([[
// Register file - {num_regs} registers x {width} bits
reg [{width}-1:0] registers [0:{num_regs}-1];

// Write port
always_ff @(posedge clk) begin
    if (rst_n == 1'b0) begin
        // Reset all registers
        for (int i = 0; i < {num_regs}; i++) begin
            registers[i] <= '0;
        end
    end else if (wr_en && (wr_addr != '0)) begin // Prevent writing to R0
        registers[wr_addr] <= wr_data;
    end
end

// Read ports
assign rd_data1 = (rd_addr1 == '0) ? '0 : registers[rd_addr1];
assign rd_data2 = (rd_addr2 == '0) ? '0 : registers[rd_addr2];
]], {
    num_regs = i(1, '32'),
    width = i(2, 'DATA_WIDTH'),
  })),

  -- =============================================================================
  -- Timing and Constraints
  -- =============================================================================
  
  -- Timing constraint comments
  s('timing', {
    t({
      '// Timing constraints (for synthesis)',
      '// Max delay: XXX ns',
      '// Setup time: XXX ns', 
      '// Hold time: XXX ns',
      '// Clock frequency: XXX MHz',
      '',
    }),
  }),

  -- Synthesis attributes
  s('synth', fmt([[
(* {attribute} = "{value}" *) {declaration}
]], {
    attribute = c(1, { 
      t('keep'),
      t('dont_touch'),
      t('max_fanout'),
      t('ram_style'),
      t('rom_style'),
    }),
    value = i(2, 'true'),
    declaration = i(0, 'wire signal_name;'),
  })),
}