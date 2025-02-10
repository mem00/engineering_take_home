import React, { useState, useEffect } from 'react';
import BuildingCard from './BuildingCard.js'
import BuildingForm from './BuildingForm.js'

const BuildingList = () => {
  // WOULD BE current_user
  const CLIENT_ID = 5
  const [buildings, setBuildings] = useState([]);
  const [showForm, setShowForm] = useState(false);
  const [error, setError] = useState(null);
  const [formErrors, setFormErrors] = useState([]);
  const [selectedBuilding, setSelectedBuilding] = useState(null);
  const [page, setPage] = useState(1);
 
  const fetchBuildings = () => {
    fetch(`/api/buildings?client_id=${CLIENT_ID}&page=${page}`)
      .then(res => res.json())
      .then(data => setBuildings(data.buildings));
  };

  useEffect(() => {
    fetchBuildings()
  }, [page]);

  const handleFormSubmit = async (formData) => {
    try {
      setFormErrors([]);
      const url = selectedBuilding?.id 
        ? `/api/buildings/${selectedBuilding.id}`
        : '/api/buildings';
      
      const method = selectedBuilding?.id ? 'PUT' : 'POST';
  
      const response = await fetch(url, {
        method,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          building: {
            ...formData,
            client_id: CLIENT_ID
          }
        })
      });
  
      const data = await response.json();
  
      if (!response.ok) {
        if (data.errors) {
          setFormErrors(data.errors);
        } else {
          throw new Error(data.message || 'Failed to save building');
        }
        return;
      }
  
      if (selectedBuilding?.id) {
        setBuildings(prev => 
          prev.map(b => b.id === data.id ? data : b)
        );
      } else {
        const refreshResponse = await fetch(`/api/buildings?client_id=${CLIENT_ID}&page=${page}`);
        const refreshData = await refreshResponse.json();
        setBuildings(refreshData.buildings);
      }
      
      setShowForm(false);
      setSelectedBuilding(null);
    } catch (err) {
      setError(err.message);
    }
  };

  if (error) return <div>Error: {error}</div>;

  return(
    <div>
      <div className="header">
        <button onClick={() => {
          setSelectedBuilding(null);
          setShowForm(true);
        }}>
          New Building
        </button>
      </div>
      <div>
        {buildings.map(building => (
          <BuildingCard
            key={building.id}
            building={building}
            onEdit={(building) => {
              setSelectedBuilding(building);
              setShowForm(true);
            }}
          />
        ))}
      </div>
      {showForm && (
        <BuildingForm
          building={selectedBuilding}
          clientId={CLIENT_ID}
          errors={formErrors}
          onClose={() => {
            setShowForm(false);
            setSelectedBuilding(null);
            setFormErrors([]);
          }}
          onSubmit={handleFormSubmit}
        />
      )}
    </div>
  )
}

export default BuildingList;
