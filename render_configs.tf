/* This will use the output variables to update the firewall configuration template
   to reflect the proper parameters for the VPNs/BGP/etc. After you run "terraform apply",
   run "terraform output transit_fw1_config > templates/transit_fw1_config.xml" then
   update the firewall's configurations.
*/

data "template_file" "transit_fw1_config" {
  template   = "${file("templates/transit_fw1_config")}"
  depends_on = ["aws_vpn_gateway_route_propagation.spoke_route_propagation"]

  vars {
    firewall_untrust_public_ip  = "${aws_eip.firewall_1_untrust_public_ip.public_ip}"
    spoke_to_transit_tunnel_1   = "${aws_vpn_connection.spoke_to_transit_fw1.tunnel1_cgw_inside_address}"
    spoke_to_transit_tunnel_2   = "${aws_vpn_connection.spoke_to_transit_fw1.tunnel2_cgw_inside_address}"
    tunnel1_vgw_inside_address  = "${aws_vpn_connection.spoke_to_transit_fw1.tunnel1_vgw_inside_address}"
    tunnel2_vgw_inside_address  = "${aws_vpn_connection.spoke_to_transit_fw1.tunnel2_vgw_inside_address}"
    tunnel1_vgw_outside_address = "${aws_vpn_connection.spoke_to_transit_fw1.tunnel1_address}"
    tunnel2_vgw_outside_address = "${aws_vpn_connection.spoke_to_transit_fw1.tunnel2_address}"
    tunnel1_preshared_key       = "${aws_vpn_connection.spoke_to_transit_fw1.tunnel1_preshared_key}"
    tunnel2_preshared_key       = "${aws_vpn_connection.spoke_to_transit_fw1.tunnel2_preshared_key}"
    tunnel1_peer_as             = "${aws_vpn_connection.spoke_to_transit_fw1.tunnel1_bgp_asn}"
    tunnel2_peer_as             = "${aws_vpn_connection.spoke_to_transit_fw1.tunnel2_bgp_asn}"
  }
}

resource "local_file" "transit_fw1_config" {
  content  = "${data.template_file.transit_fw1_config.rendered}"
  filename = "templates/transit_fw1_config.xml"
}


data "template_file" "fw1_config_push" {
  template   = "${file("templates/fw1_config_push")}"
  depends_on = ["aws_vpn_gateway_route_propagation.spoke_route_propagation"]

  vars {
    fw1_mgmt_ip  = "${aws_eip.firewall_1_management_public_ip.public_ip}"
    tunnel1_preshared_key       = "${aws_vpn_connection.spoke_to_transit_fw1.tunnel1_preshared_key}"
    tunnel2_preshared_key       = "${aws_vpn_connection.spoke_to_transit_fw1.tunnel2_preshared_key}"
  }
}

resource "local_file" "fw1_config_push" {
  content  = "${data.template_file.fw1_config_push.rendered}"
  filename = "templates/fw1_config_push.sh"
}
