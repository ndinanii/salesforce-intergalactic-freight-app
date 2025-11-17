const jsforce = require('jsforce');

class SalesforceService {
  constructor() {
    this.conn = null;
  }

  async connect() {
    if (this.conn) {
      return this.conn;
    }

    try {
      this.conn = new jsforce.Connection({
        loginUrl: process.env.SF_LOGIN_URL || 'https://login.salesforce.com'
      });

      await this.conn.login(
        process.env.SF_USERNAME,
        process.env.SF_PASSWORD + process.env.SF_SECURITY_TOKEN
      );

      console.log('✅ Connected to Salesforce');
      return this.conn;
    } catch (error) {
      console.error('❌ Salesforce connection error:', error);
      throw error;
    }
  }

  async query(soql) {
    const conn = await this.connect();
    return conn.query(soql);
  }

  async create(objectType, data) {
    const conn = await this.connect();
    return conn.sobject(objectType).create(data);
  }

  async update(objectType, data) {
    const conn = await this.connect();
    return conn.sobject(objectType).update(data);
  }

  async delete(objectType, id) {
    const conn = await this.connect();
    return conn.sobject(objectType).delete(id);
  }

  async retrieve(objectType, id) {
    const conn = await this.connect();
    return conn.sobject(objectType).retrieve(id);
  }
}

module.exports = new SalesforceService();
