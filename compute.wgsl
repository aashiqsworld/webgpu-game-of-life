@group(0) @binding(0) var<uniform> grid: vec2f;

@group(0) @binding(1) var<storage> cellStateIn: array<u32>;
@group(0) @binding(2) var<storage, read_write> cellStateOut: array<u32>;
// converts x,y cell value into instance_id
fn cellIndex(cell: vec2u) -> u32 {
	return 	(cell.y % u32(grid.y)) * u32(grid.x) + 
			(cell.x % u32(grid.x));
}

@compute @workgroup_size(${WORKGROUP_SIZE}, ${WORKGROUP_SIZE})
fn computeMain(@builtin(global_invocation_id) cell: vec3u) {\

	let activeNeighbors = 	cellActive(cell.x+1, cell.y+1) + 
							cellActive(cell.x+1, cell.y) + 
							cellActive(cell.x+1, cell.y-1) + 
							cellActive(cell.x, cell.y-1) + 
							cellActive(cell.x-1, cell.y-1) +
							cellActive(cell.x-1, cell.y) +
							cellActive(cell.x-1, cell.y+1) +
							cellActive(cell.x, cell.y+1);

	let i = cellIndex(cell.xy);

	// conway's game of life rules
	switch activeNeighbors {
		case 2: { // 2 neighbors, stay active
			cellStateOut[i] = cellStateIn[i];
		}
		case 3: { // 3 neighbors, become or stay active
			cellStateOut[i] = 1;
		}
		default: { // less than 2 or more than 3 become inactive
			cellStateOut[i] = 0;
		}
	}
}

fn cellActive(x: u32, y: u32) -> u32 {
	return cellStateIn[cellIndex(vec2(x, y))];
}