import React from 'react';

const BuildingCard = ({ building, onEdit }) => {
  return (
    <div>
      <h3> {building.address} {building.city}, {building.state_abbr} {building.postal_code} </h3>
      { Object.entries(building).map(([key, value]) => {
        if (!['id', 'address', 'city', 'state_abbr', 'postal_code'].includes(key)) {
          return (
            <div key={key}>
              <strong>{key}:</strong> {value || 'N/A'}
            </div>
          );
        }
      })}
      <button onClick={() => onEdit(building)}>
        Edit
      </button>
    </div>
  )
}


export default BuildingCard;