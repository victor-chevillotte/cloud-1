There are two folders with two different infrastructures :

### Single domain (Recommended)
This infrastructure has only one endpoint for Wordpress and one for PhpMyAdmin  
The traffic is load balanced to multiple EC2 instances   

This is the recommended architecture for Wordpress deployment on AWS (See Readme in the single-domain folder)  


### Multi domains
This infrastructure defines endpoints (From 1 to 5 endpoints)  
Each of these endpoints represent one instance of wordpress (wp1, wp2,wp3 ..., wp5.[DOMAIN_NAME]) and one phpmyadmin  
