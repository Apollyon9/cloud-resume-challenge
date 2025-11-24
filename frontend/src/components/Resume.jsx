import React from 'react';
import './Resume.css'; // We will make this next

function Resume() {
  return (
    <main className="resume-container">
      <header>
        <h1>Your Name</h1>
        <p>Cloud Engineer | AWS Certified</p>
      </header>

      <section id="summary">
        <h2>Summary</h2>
        <p>I am a cloud engineer passionate about...</p>
      </section>

      <section id="experience">
        <h2>Experience</h2>
        <div className="job">
          <h3>Job Title</h3>
          <span>Company Name | Date</span>
          <ul>
            <li>Accomplishment 1</li>
            <li>Accomplishment 2</li>
          </ul>
        </div>
      </section>

      {/* Add Education and Certification sections here similar to above */}

    </main>
  );
}

export default Resume;