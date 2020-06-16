# terraform-jenkins-github-aws
There are many professionals with expertise in Aws,Openstack or other Cloud technology .But there are only few who are capable to integrate this technologies with each other .As a part of Multi-Hybrid-cloud training under the guidance of mr.Vimal Daga sir , here is my first project/task to integrate the above technologies .I have build this "IaaS -Infrastructure as a Code-" for deploying your websites on cloud by "automating end-to-end". The project will perform the following task:
1.Create the following AWS automation of website in Terraform

2. Create the key and download in local file and create security group which allow the port 80.

3. Launch EC2 instance.

4. In this Ec2 instance use the key and security group which we have created in step 2.

5. Launch one Volume (EBS) and mount that volume into /var/www/html

6. Developer have uploded the code into github repo also the repo has some images.

7. Copy the github repo code into /var/www/html

8. Create S3 bucket, and copy/deploy the images from github repo into the s3 bucket and change the permission to public readable.

9 Create a Cloudfront using s3 bucket(which contains images) and use the Cloudfront URL to update in code in /var/www/html

10) Those who are familiar with jenkins or are in devops AL have to integrate jenkins in this task wherever you feel can be integrated
