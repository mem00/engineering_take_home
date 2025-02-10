import React, { useState, useEffect } from 'react';

const BuildingForm = ({ building, clientId, errors, onClose, onSubmit}) => {
  const [customFields, setCustomFields] = useState([])
  const [formData, setFormData] = useState({
    address: building?.address || '',
    city: building?.city || '',
    state_abbr: building?.state_abbr || '',
    postal_code: building?.postal_code || ''
  })

  useEffect(() => {
    fetch(`/api/custom_fields?client_id=${clientId}`)
      .then(res => res.json())
      .then(data => {

        setCustomFields(data.custom_fields)
        const customFieldsForm = data.custom_fields.reduce((acc, field) => {
          acc[field.name] = building?.id ? building[field.name] || "" : "";
          return acc;
        }, {});
        console.log(customFieldsForm)

        setFormData(prevData => ({ ...prevData, ...customFieldsForm}))
      })
  }, [building, clientId]);

  const handleChange = (e) => {
    setFormData(prev => ({
      ...prev,
      [e.target.name]: e.target.value
    }));
  };

  return (
    <div className="form-modal">
      <div className="form-content">
        <h2>{building?.id ? 'Edit Building' : 'New Building'}</h2>

        {errors?.length > 0 && (
          <div style={{ color: 'red', marginBottom: '16px' }}>
            {errors.map((error, index) => (
              <div key={index}>{error}</div>
            ))}
          </div>
        )}
        <div className="form-group">
          <label>Address:</label>
            <input
              name="address"
              value={formData.address}
              onChange={handleChange}
              required
            />
        </div>
        <div className="form-group">
          <label>City:</label>
          <input
            name="city"
            value={formData.city}
            onChange={handleChange}
            required
          />
        </div>

        <div className="form-group">
          <label>State Abbr:</label>
          <input
            name="state_abbr"
            value={formData.state_abbr}
            onChange={handleChange}
            maxLength="2"
            required
          />
        </div>

        <div className="form-group">
            <label>Postal Code:</label>
            <input
              name="postal_code"
              value={formData.postal_code}
              onChange={handleChange}
              require
            />
        </div>
        {customFields.map(field => (
          <div key={field.name} className="form-group">
            <label>{field.name}:</label>
            {field.field_type === 'enumeration' ? (
              <select
                name={field.name}
                value={formData[field.name] || ''}
                onChange={handleChange}
              >
                <option value="">Select {field.name}</option>
                {field.options?.map(option => (
                  <option key={option} value={option}>{option}</option>
                ))}
              </select>
            ) : (
              <input
                type={field.field_type === 'number' ? 'number' : 'text'}
                name={field.name}
                value={formData[field.name] || ''}
                onChange={handleChange}
              />
            )}
          </div>
        ))}

        <div className="form-actions">
          <button onClick={() => onSubmit(formData)}>Save</button>
          <button onClick={onClose}>Cancel</button>
        </div>
      </div>
  </div>
  );
};

export default BuildingForm;
