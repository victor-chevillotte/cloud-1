There are two folders with two different infrastructure :

### Single domain (Recommended)
This infrastructure has only one endpoint for wordpress and one for PhpMyAdmin. It splits the traffic to different EC2.

### Multi domains
This infrastructure defines endpoints (From 1 to 5 endpoints). Each of these endpoints represent one wordpress(wp1, wp2,wp3 ..., wp5.mdeseoeuv.com) and one phpmyadmin.


To Do :

- [ ] : Retrain CloudFront cache to specific file types (.css, .jpg, etc...) Mehdi
- [-] : Readme multi domains
- [-] : Ingress sg wordpress
- [ ] : Health Check