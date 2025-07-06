# Production ARM Templates

## Setup Instructions

1. **Copy sandbox templates:**
   ```bash
   cp ../sandbox-arm/* ./
   ```

2. **Customize for production:**
   - Use larger VM sizes (Standard_D4s_v3 or higher)
   - Configure multiple availability zones
   - Set up load balancers for high availability
   - Use managed databases instead of local storage

3. **Security enhancements:**
   - Enable Azure Security Center
   - Configure Azure Monitor alerts
   - Set up Key Vault access policies
   - Implement Azure AD integration

4. **Update parameters:**
   - Change default passwords
   - Configure proper domain names
   - Set production-grade resource sizes

## Production Checklist

- [ ] VM sizes appropriate for workload
- [ ] Multiple availability zones configured
- [ ] Load balancers configured
- [ ] Azure SQL/PostgreSQL for persistence
- [ ] Key Vault integration
- [ ] Monitoring and alerting
- [ ] Backup strategies
- [ ] Disaster recovery plan
- [ ] Security baseline applied
