import React, { useState, useEffect } from "react";
import axios from "axios";
import "./viewprofile.css";
import Farmer from "../assets/banana.jpg";

const ViewProfile = () => {
  const [profile, setProfile] = useState({
    name: "",
    dob: "",
    gender: "",
    contact: "",
    aadhar: "",
    farmAddress: "",
    residentialAddress: "",
    farmSize: "",
    cropsGrown: "",
    farmingMethod: "",
    aadharProof: "",
    landOwnershipProof: "",
    bankAccount: "",
    upiId: "",
    IFSCcode: "",
    photo: "", // Add photo field
  });

  useEffect(() => {
    axios
      .get("http://localhost:5000/api/farmer-profile")
      .then((response) => {
        setProfile(response.data);
      })
      .catch((error) => console.error("Error fetching profile:", error));
  }, []);

  return (
    <div className="view-profile-page">
      <div className="profile-container">
        <h2 className="profile-title">The Face Behind the Fields</h2>
        <div className="profile">
          <div className="profile-header">
            <img
              src={profile.photo || Farmer} // Fallback to a placeholder if no photo is provided
              alt="Farmer"
              className="profile-image"
            />
            <h3 className="profile-name">Name: {profile.name }</h3>
            <p className="profile-id">ID: {profile.id }</p>
          </div>

          <div className="profile-details">
            {/* Personal Details */}
            <div className="detail-section">
              <h4 className="section-title">Personal Details</h4>
              <div className="detail-item">
                <span className="detail-label">DOB:</span>
                <span className="detail-value">{profile.dob }</span>
              </div>
              <div className="detail-item">
                <span className="detail-label">Gender:</span>
                <span className="detail-value">{profile.gender }</span>
              </div>
              <div className="detail-item">
                <span className="detail-label">Contact No:</span>
                <span className="detail-value">{profile.contact }</span>
              </div>
              <div className="detail-item">
                <span className="detail-label">Aadhar No:</span>
                <span className="detail-value">{profile.aadhar }</span>
              </div>
            </div>

            {/* Farm Details */}
            <div className="detail-section">
              <h4 className="section-title">Farm Details</h4>
              <div className="detail-item">
                <span className="detail-label">Farm Address:</span>
                <span className="detail-value">{profile.farmAddress}</span>
              </div>
              <div className="detail-item">
                <span className="detail-label">Residential Address:</span>
                <span className="detail-value">
                  {profile.residentialAddress }
                </span>
              </div>
              <div className="detail-item">
                <span className="detail-label">Farm Size:</span>
                <span className="detail-value">{profile.farmSize}</span>
              </div>
              <div className="detail-item">
                <span className="detail-label">Types of Crops Grown:</span>
                <span className="detail-value">{profile.cropsGrown }</span>
              </div>
              <div className="detail-item">
                <span className="detail-label">Farming Method:</span>
                <span className="detail-value">{profile.farmingMethod }</span>
              </div>
            </div>

            {/* Proofs and Documents */}
            <div className="detail-section">
              <h4 className="section-title">Proofs and Documents</h4>
              <div className="detail-item">
                <span className="detail-label">Aadhar Proof:</span>
                <span className="detail-value">
                  {profile.aadharProof ? (
                    <a href={profile.aadharProof} download className="download-link">
                      Download
                    </a>
                  ) : (
                    ""
                  )}
                </span>
              </div>
              <div className="detail-item">
                <span className="detail-label">Land Ownership Proof:</span>
                <span className="detail-value">
                  {profile.landOwnershipProof ? (
                    <a href={profile.landOwnershipProof} download className="download-link">
                      Download
                    </a>
                  ) : (
                    ""
                  )}
                </span>
              </div>
            </div>

            {/* Banking Details */}
            <div className="detail-section">
              <h4 className="section-title">Banking Details</h4>
              <div className="detail-item">
                <span className="detail-label">Bank Account No:</span>
                <span className="detail-value">{profile.bankAccount }</span>
              </div>
              <div className="detail-item">
                <span className="detail-label">UPI ID:</span>
                <span className="detail-value">{profile.upiId }</span>
              </div>
              <div className="detail-item">
                <span className="detail-label">IFSC Code:</span>
                <span className="detail-value">{profile.IFSCcode }</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ViewProfile;