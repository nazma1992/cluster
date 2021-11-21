provider "aws" {
  access_key = "PQPU7R"
  secret_key = "yxenunmKBVNNYPeI"
  region     = "us-east-1"
	
}

#data
data "aws_availability_zones" "azs" {
state = "available"
}


resource "aws_vpc" "myvpc" {
	cidr_block = "10.0.0.0/16"
        enable_dns_support   = true
        enable_dns_hostnames = true
 
tags = {

Name = "vpc1"

}
}


		

  resource "aws_internet_gateway" "igw" {
	vpc_id = "${aws_vpc.myvpc.id}"
	   tags = {
         Name = "igw1"
        }
		
	}
  

resource "aws_subnet" "privatesubnet1" {
	vpc_id = "${aws_vpc.myvpc.id}"
	cidr_block = "10.0.0.0/24"
	map_public_ip_on_launch = "true"
	availability_zone = "${data.aws_availability_zones.azs.names[0]}"
	tags  = {

Name = "prisubnet1"

}
	}

resource "aws_subnet" "publicsubnet1" {
  vpc_id = "${aws_vpc.myvpc.id}"
cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "${data.aws_availability_zones.azs.names[0]}"
  tags = {
   Name = "pubsubnet1"
  }
}

resource "aws_route_table" "publicrtb" {
	vpc_id = "${aws_vpc.myvpc.id}"

	route {
    	cidr_block = "0.0.0.0/0"
    	gateway_id = "${aws_internet_gateway.igw.id}"
  	}
  
    	tags =  {
		Names = "rtb1"
	}
  }





resource "aws_route_table_association" "rta-subnet" {
  subnet_id      = "${aws_subnet.privatesubnet1.id}"
  route_table_id = "${aws_route_table.publicrtb.id}"
}


resource "aws_route_table_association" "rta-publicsubnet" {
  subnet_id      = "${aws_subnet.publicsubnet1.id}"
  route_table_id = "${aws_route_table.publicrtb.id}"
}

	
resource "aws_security_group" "sg_22"{
name = "sg_22"
  vpc_id = "${aws_vpc.myvpc.id}"

# SSH access from the VPC
  ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

}
  tags = {
   Name = "ssh connection"
  }
}







resource "aws_instance" "Testinstance" {
ami = "${var.aws_amis}"
key_name = "${var.key_file}"
instance_type = "${var.instance_type}"
vpc_security_group_ids = ["${aws_security_group.sg_22.id}"]
root_block_device { delete_on_termination = true }
associate_public_ip_address = true
     connection {
    type = "ssh"
    user = "ubuntu"
        host = "${aws_instance.Testinstance.public_ip}"
#    private_key = "${file(var.key_path)}"
     } 
     
 



  tags =  {
   Name = "TestVM"
        }
}

resource "aws_eip" "ip" {
  instance = "${aws_instance.Testinstance.id}"
}
 

