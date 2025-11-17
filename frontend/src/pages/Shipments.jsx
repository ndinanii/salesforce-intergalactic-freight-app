import React from 'react';
import { Typography, Paper, Box, Button } from '@mui/material';
import { useQuery } from 'react-query';
import { shipmentApi } from '../services/api';

function Shipments() {
  const { data: shipments, isLoading, error } = useQuery('shipments', () => 
    shipmentApi.getAll().then(res => res.data)
  );

  if (isLoading) return <Typography>Loading shipments...</Typography>;
  if (error) return <Typography color="error">Error loading shipments: {error.message}</Typography>;

  return (
    <Box>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 3 }}>
        <Typography variant="h4">Shipments</Typography>
        <Button variant="contained" color="primary">
          New Shipment
        </Button>
      </Box>
      
      <Paper sx={{ p: 3 }}>
        <Typography variant="body1">
          Total Shipments: {shipments?.data?.length || 0}
        </Typography>
        <Typography color="text.secondary" sx={{ mt: 2 }}>
          Shipment list will be displayed here. Integrate with Salesforce API for live data.
        </Typography>
      </Paper>
    </Box>
  );
}

export default Shipments;
