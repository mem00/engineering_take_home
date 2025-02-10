import React, { useState, useEffect } from 'react';
import BuildingCard from './BuidlingCard.js'

const BuildingList = () => {
  // WOULD BE current_user
  const CLIENT_ID = 5
  const [buildings, setBuildings] = useState([]);
  const [customFieldsConfig, setCustomFieldsConfig] = useState([]);
  const [page, setPage] = useState(1);
 
  const fetchBuildings = () => {
    fetch(`/api/buildings?client_id=${CLIENT_ID}&page=${page}`)
      .then(res => res.json())
      .then(data => {
        console.log("API Response:", data.buildings)
        setBuildings(data.buildings)
        }
      );
  };

  useEffect(() => {
    fetchBuildings()
  }, [page]);

  return(
    <div>
      {buildings.map(building => (
        <BuildingCard
          key={building.id}
          building={building}
        />
      ))}
    </div>
  )
}

export default BuildingList;
