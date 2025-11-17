import React from 'react';
import { Typography, Grid, Paper, Box } from '@mui/material';
import { useQuery } from 'react-query';
import { shipmentApi } from '../services/api';

function Dashboard() {
  const { data: shipments, isLoading } = useQuery('activeShipments', () => 
    shipmentApi.getActive().then(res => res.data)
  );

  return (
    <Box>
      <Typography variant="h4" gutterBottom>
        Dashboard
      </Typography>
      
      <Grid container spacing={3}>
        <Grid item xs={12} md={4}>
          <Paper sx={{ p: 3, textAlign: 'center' }}>
            <Typography variant="h6" color="text.secondary">
              Active Shipments
            </Typography>
            <Typography variant="h3">
              {isLoading ? '...' : shipments?.data?.length || 0}
            </Typography>
          </Paper>
        </Grid>
        
        <Grid item xs={12} md={4}>
          <Paper sx={{ p: 3, textAlign: 'center' }}>
            <Typography variant="h6" color="text.secondary">
              Total Cargo
            </Typography>
            <Typography variant="h3">
              --
            </Typography>
          </Paper>
        </Grid>
        
        <Grid item xs={12} md={4}>
          <Paper sx={{ p: 3, textAlign: 'center' }}>
            <Typography variant="h6" color="text.secondary">
              Active Agents
            </Typography>
            <Typography variant="h3">
              --
            </Typography>
          </Paper>
        </Grid>
      </Grid>

      <Box sx={{ mt: 4 }}>
        <Typography variant="h5" gutterBottom>
          Recent Activity
        </Typography>
        <Paper sx={{ p: 3 }}>
          <Typography color="text.secondary">
            Connect your backend API to see real-time data from Salesforce
          </Typography>
        </Paper>
      </Box>
    </Box>
  );
}

export default Dashboard;
