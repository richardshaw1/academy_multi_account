# ======================================================================================================================
# Route Table Association - Associate subnets with the Route Table
# ======================================================================================================================
# ===================================================================================================================
# VARIABLES
# ===================================================================================================================
# ======================================================================================================================
# RESOURCE CREATION
# ======================================================================================================================
resource "aws_route_table_association" "rt_bl_asocn" {
  count          = length(var.subnet_names)
  subnet_id      = aws_subnet.env_subnet[count.index].id
  route_table_id = element(aws_route_table.env_rt_tbl.*.id, count.index)
}


/* resource "aws_route_table_association" "subnet_01_rt_tbl_asocn" {

  subnet_id      = aws_subnet.subnet[0].id
  route_table_id = aws_route_table.subnet_01_rt.id
}
resource "aws_route_table_association" "subnet_02_rt_tbl_asocn" {
  subnet_id      = aws_subnet.subnet[1].id
  route_table_id = aws_route_table.subnet_02_rt.id
} */
