String getResumeForm() {
  return r'''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Resume Form</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
        }
        fieldset {
            border: 1px solid #ddd;
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 5px;
        }
        legend {
            font-weight: bold;
            padding: 0 10px;
        }
        .form-group {
            margin-bottom: 15px;
        }
        label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        input[type="text"],
        input[type="email"],
        input[type="tel"],
        input[type="url"],
        input[type="date"],
        textarea,
        select {
            width: 100%;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-sizing: border-box;
        }
        textarea {
            height: 80px;
        }
        button {
            background-color: #4CAF50;
            color: white;
            padding: 8px 12px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            margin-right: 5px;
        }
        button:hover {
            background-color: #45a049;
        }
        .array-item {
            border: 1px solid #eee;
            padding: 10px;
            margin-bottom: 15px;
            position: relative;
        }
        .remove-btn {
            background-color: #f44336;
            position: absolute;
            top: 5px;
            right: 5px;
        }
        .add-btn {
            margin-bottom: 15px;
        }
    </style>
</head>
<body>
    <h1>Resume Form</h1>
    <form>
        <!-- Basics Section -->
        <fieldset>
            <legend>Basic Information</legend>
            
            <div class="form-group">
                <label for="basics_name">Full Name</label>
                <input type="text" id="basics_name" name="basics[name]" required>
            </div>
            
            <div class="form-group">
                <label for="basics_label">Professional Label</label>
                <input type="text" id="basics_label" name="basics[label]">
            </div>
            
            <div class="form-group">
                <label for="basics_image">Image URL</label>
                <input type="url" id="basics_image" name="basics[image]">
            </div>
            
            <div class="form-group">
                <label for="basics_email">Email</label>
                <input type="email" id="basics_email" name="basics[email]" required>
            </div>
            
            <div class="form-group">
                <label for="basics_phone">Phone</label>
                <input type="tel" id="basics_phone" name="basics[phone]">
            </div>
            
            <div class="form-group">
                <label for="basics_url">Website URL</label>
                <input type="url" id="basics_url" name="basics[url]">
            </div>
            
            <div class="form-group">
                <label for="basics_summary">Summary</label>
                <textarea id="basics_summary" name="basics[summary]"></textarea>
            </div>
            
            <!-- Location Subsection -->
            <fieldset>
                <legend>Location</legend>
                
                <div class="form-group">
                    <label for="basics_location_address">Address</label>
                    <input type="text" id="basics_location_address" name="basics[location][address]">
                </div>
                
                <div class="form-group">
                    <label for="basics_location_postalCode">Postal Code</label>
                    <input type="text" id="basics_location_postalCode" name="basics[location][postalCode]">
                </div>
                
                <div class="form-group">
                    <label for="basics_location_city">City</label>
                    <input type="text" id="basics_location_city" name="basics[location][city]">
                </div>
                
                <div class="form-group">
                    <label for="basics_location_countryCode">Country Code</label>
                    <input type="text" id="basics_location_countryCode" name="basics[location][countryCode]">
                </div>
                
                <div class="form-group">
                    <label for="basics_location_region">Region/State</label>
                    <input type="text" id="basics_location_region" name="basics[location][region]">
                </div>
            </fieldset>
            
            <!-- Profiles Array -->
            <div id="profiles-container">
                <legend>Social Profiles</legend>
                <button type="button" class="add-btn" onclick="addProfile()">+ Add Profile</button>
                <div class="array-item" id="profile-0">
                    <div class="form-group">
                        <label for="basics_profiles_0_network">Network</label>
                        <input type="text" id="basics_profiles_0_network" name="basics[profiles][0][network]">
                    </div>
                    
                    <div class="form-group">
                        <label for="basics_profiles_0_username">Username</label>
                        <input type="text" id="basics_profiles_0_username" name="basics[profiles][0][username]">
                    </div>
                    
                    <div class="form-group">
                        <label for="basics_profiles_0_url">Profile URL</label>
                        <input type="url" id="basics_profiles_0_url" name="basics[profiles][0][url]">
                    </div>
                </div>
            </div>
        </fieldset>
        
        <!-- Work Experience Array -->
        <fieldset id="work-container">
            <legend>Work Experience</legend>
            <button type="button" class="add-btn" onclick="addWork()">+ Add Work Experience</button>
            <div class="array-item" id="work-0">
                <div class="form-group">
                    <label for="work_0_name">Company Name</label>
                    <input type="text" id="work_0_name" name="work[0][name]">
                </div>
                
                <div class="form-group">
                    <label for="work_0_position">Position</label>
                    <input type="text" id="work_0_position" name="work[0][position]">
                </div>
                
                <div class="form-group">
                    <label for="work_0_url">Company URL</label>
                    <input type="url" id="work_0_url" name="work[0][url]">
                </div>
                
                <div class="form-group">
                    <label for="work_0_startDate">Start Date</label>
                    <input type="date" id="work_0_startDate" name="work[0][startDate]">
                </div>
                
                <div class="form-group">
                    <label for="work_0_endDate">End Date</label>
                    <input type="date" id="work_0_endDate" name="work[0][endDate]">
                </div>
                
                <div class="form-group">
                    <label for="work_0_summary">Summary</label>
                    <textarea id="work_0_summary" name="work[0][summary]"></textarea>
                </div>
                
                <!-- Highlights Array -->
                <div id="work-highlights-container-0">
                    <legend>Highlights</legend>
                    <button type="button" class="add-btn" onclick="addWorkHighlight(0)">+ Add Highlight</button>
                    <div class="array-item">
                        <div class="form-group">
                            <label for="work_0_highlights_0">Highlight</label>
                            <input type="text" id="work_0_highlights_0" name="work[0][highlights][0]">
                        </div>
                    </div>
                </div>
            </div>
        </fieldset>
        
        <!-- Volunteer Experience Array -->
        <fieldset id="volunteer-container">
            <legend>Volunteer Experience</legend>
            <button type="button" class="add-btn" onclick="addVolunteer()">+ Add Volunteer Experience</button>
            <div class="array-item" id="volunteer-0">
                <div class="form-group">
                    <label for="volunteer_0_organization">Organization</label>
                    <input type="text" id="volunteer_0_organization" name="volunteer[0][organization]">
                </div>
                
                <div class="form-group">
                    <label for="volunteer_0_position">Position</label>
                    <input type="text" id="volunteer_0_position" name="volunteer[0][position]">
                </div>
                
                <div class="form-group">
                    <label for="volunteer_0_url">Organization URL</label>
                    <input type="url" id="volunteer_0_url" name="volunteer[0][url]">
                </div>
                
                <div class="form-group">
                    <label for="volunteer_0_startDate">Start Date</label>
                    <input type="date" id="volunteer_0_startDate" name="volunteer[0][startDate]">
                </div>
                
                <div class="form-group">
                    <label for="volunteer_0_endDate">End Date</label>
                    <input type="date" id="volunteer_0_endDate" name="volunteer[0][endDate]">
                </div>
                
                <div class="form-group">
                    <label for="volunteer_0_summary">Summary</label>
                    <textarea id="volunteer_0_summary" name="volunteer[0][summary]"></textarea>
                </div>
                
                <!-- Highlights Array -->
                <div id="volunteer-highlights-container-0">
                    <legend>Highlights</legend>
                    <button type="button" class="add-btn" onclick="addVolunteerHighlight(0)">+ Add Highlight</button>
                    <div class="array-item">
                        <div class="form-group">
                            <label for="volunteer_0_highlights_0">Highlight</label>
                            <input type="text" id="volunteer_0_highlights_0" name="volunteer[0][highlights][0]">
                        </div>
                    </div>
                </div>
            </div>
        </fieldset>
        
        <!-- Education Array -->
        <fieldset id="education-container">
            <legend>Education</legend>
            <button type="button" class="add-btn" onclick="addEducation()">+ Add Education</button>
            <div class="array-item" id="education-0">
                <div class="form-group">
                    <label for="education_0_institution">Institution</label>
                    <input type="text" id="education_0_institution" name="education[0][institution]">
                </div>
                
                <div class="form-group">
                    <label for="education_0_url">Institution URL</label>
                    <input type="url" id="education_0_url" name="education[0][url]">
                </div>
                
                <div class="form-group">
                    <label for="education_0_area">Area of Study</label>
                    <input type="text" id="education_0_area" name="education[0][area]">
                </div>
                
                <div class="form-group">
                    <label for="education_0_studyType">Degree Type</label>
                    <input type="text" id="education_0_studyType" name="education[0][studyType]">
                </div>
                
                <div class="form-group">
                    <label for="education_0_startDate">Start Date</label>
                    <input type="date" id="education_0_startDate" name="education[0][startDate]">
                </div>
                
                <div class="form-group">
                    <label for="education_0_endDate">End Date</label>
                    <input type="date" id="education_0_endDate" name="education[0][endDate]">
                </div>
                
                <div class="form-group">
                    <label for="education_0_score">GPA/Score</label>
                    <input type="text" id="education_0_score" name="education[0][score]">
                </div>
                
                <!-- Courses Array -->
                <div id="education-courses-container-0">
                    <legend>Courses</legend>
                    <button type="button" class="add-btn" onclick="addCourse(0)">+ Add Course</button>
                    <div class="array-item">
                        <div class="form-group">
                            <label for="education_0_courses_0">Course</label>
                            <input type="text" id="education_0_courses_0" name="education[0][courses][0]">
                        </div>
                    </div>
                </div>
            </div>
        </fieldset>
        
        <!-- Awards Array -->
        <fieldset id="awards-container">
            <legend>Awards</legend>
            <button type="button" class="add-btn" onclick="addAward()">+ Add Award</button>
            <div class="array-item" id="award-0">
                <div class="form-group">
                    <label for="awards_0_title">Title</label>
                    <input type="text" id="awards_0_title" name="awards[0][title]">
                </div>
                
                <div class="form-group">
                    <label for="awards_0_date">Date</label>
                    <input type="date" id="awards_0_date" name="awards[0][date]">
                </div>
                
                <div class="form-group">
                    <label for="awards_0_awarder">Awarder</label>
                    <input type="text" id="awards_0_awarder" name="awards[0][awarder]">
                </div>
                
                <div class="form-group">
                    <label for="awards_0_summary">Summary</label>
                    <textarea id="awards_0_summary" name="awards[0][summary]"></textarea>
                </div>
            </div>
        </fieldset>
        
        <!-- Certificates Array -->
        <fieldset id="certificates-container">
            <legend>Certificates</legend>
            <button type="button" class="add-btn" onclick="addCertificate()">+ Add Certificate</button>
            <div class="array-item" id="certificate-0">
                <div class="form-group">
                    <label for="certificates_0_name">Name</label>
                    <input type="text" id="certificates_0_name" name="certificates[0][name]">
                </div>
                
                <div class="form-group">
                    <label for="certificates_0_date">Date</label>
                    <input type="date" id="certificates_0_date" name="certificates[0][date]">
                </div>
                
                <div class="form-group">
                    <label for="certificates_0_issuer">Issuer</label>
                    <input type="text" id="certificates_0_issuer" name="certificates[0][issuer]">
                </div>
                
                <div class="form-group">
                    <label for="certificates_0_url">Certificate URL</label>
                    <input type="url" id="certificates_0_url" name="certificates[0][url]">
                </div>
            </div>
        </fieldset>
        
        <!-- Publications Array -->
        <fieldset id="publications-container">
            <legend>Publications</legend>
            <button type="button" class="add-btn" onclick="addPublication()">+ Add Publication</button>
            <div class="array-item" id="publication-0">
                <div class="form-group">
                    <label for="publications_0_name">Name</label>
                    <input type="text" id="publications_0_name" name="publications[0][name]">
                </div>
                
                <div class="form-group">
                    <label for="publications_0_publisher">Publisher</label>
                    <input type="text" id="publications_0_publisher" name="publications[0][publisher]">
                </div>
                
                <div class="form-group">
                    <label for="publications_0_releaseDate">Release Date</label>
                    <input type="date" id="publications_0_releaseDate" name="publications[0][releaseDate]">
                </div>
                
                <div class="form-group">
                    <label for="publications_0_url">Publication URL</label>
                    <input type="url" id="publications_0_url" name="publications[0][url]">
                </div>
                
                <div class="form-group">
                    <label for="publications_0_summary">Summary</label>
                    <textarea id="publications_0_summary" name="publications[0][summary]"></textarea>
                </div>
            </div>
        </fieldset>
        
        <!-- Skills Array -->
        <fieldset id="skills-container">
            <legend>Skills</legend>
            <button type="button" class="add-btn" onclick="addSkill()">+ Add Skill</button>
            <div class="array-item" id="skill-0">
                <div class="form-group">
                    <label for="skills_0_name">Skill Name</label>
                    <input type="text" id="skills_0_name" name="skills[0][name]">
                </div>
                
                <div class="form-group">
                    <label for="skills_0_level">Level</label>
                    <select id="skills_0_level" name="skills[0][level]">
                        <option value="">Select level</option>
                        <option value="Beginner">Beginner</option>
                        <option value="Intermediate">Intermediate</option>
                        <option value="Advanced">Advanced</option>
                        <option value="Master">Master</option>
                    </select>
                </div>
                
                <!-- Keywords Array -->
                <div id="skill-keywords-container-0">
                    <legend>Keywords</legend>
                    <button type="button" class="add-btn" onclick="addSkillKeyword(0)">+ Add Keyword</button>
                    <div class="array-item">
                        <div class="form-group">
                            <label for="skills_0_keywords_0">Keyword</label>
                            <input type="text" id="skills_0_keywords_0" name="skills[0][keywords][0]">
                        </div>
                    </div>
                </div>
            </div>
        </fieldset>
        
        <!-- Languages Array -->
        <fieldset id="languages-container">
            <legend>Languages</legend>
            <button type="button" class="add-btn" onclick="addLanguage()">+ Add Language</button>
            <div class="array-item" id="language-0">
                <div class="form-group">
                    <label for="languages_0_language">Language</label>
                    <input type="text" id="languages_0_language" name="languages[0][language]">
                </div>
                
                <div class="form-group">
                    <label for="languages_0_fluency">Fluency</label>
                    <input type="text" id="languages_0_fluency" name="languages[0][fluency]">
                </div>
            </div>
        </fieldset>
        
        <!-- Interests Array -->
        <fieldset id="interests-container">
            <legend>Interests</legend>
            <button type="button" class="add-btn" onclick="addInterest()">+ Add Interest</button>
            <div class="array-item" id="interest-0">
                <div class="form-group">
                    <label for="interests_0_name">Interest Name</label>
                    <input type="text" id="interests_0_name" name="interests[0][name]">
                </div>
                
                <!-- Keywords Array -->
                <div id="interest-keywords-container-0">
                    <legend>Keywords</legend>
                    <button type="button" class="add-btn" onclick="addInterestKeyword(0)">+ Add Keyword</button>
                    <div class="array-item">
                        <div class="form-group">
                            <label for="interests_0_keywords_0">Keyword</label>
                            <input type="text" id="interests_0_keywords_0" name="interests[0][keywords][0]">
                        </div>
                    </div>
                </div>
            </div>
        </fieldset>
        
        <!-- References Array -->
        <fieldset id="references-container">
            <legend>References</legend>
            <button type="button" class="add-btn" onclick="addReference()">+ Add Reference</button>
            <div class="array-item" id="reference-0">
                <div class="form-group">
                    <label for="references_0_name">Name</label>
                    <input type="text" id="references_0_name" name="references[0][name]">
                </div>
                
                <div class="form-group">
                    <label for="references_0_reference">Reference</label>
                    <textarea id="references_0_reference" name="references[0][reference]"></textarea>
                </div>
            </div>
        </fieldset>
        
        <!-- Projects Array -->
        <fieldset id="projects-container">
            <legend>Projects</legend>
            <button type="button" class="add-btn" onclick="addProject()">+ Add Project</button>
            <div class="array-item" id="project-0">
                <div class="form-group">
                    <label for="projects_0_name">Project Name</label>
                    <input type="text" id="projects_0_name" name="projects[0][name]">
                </div>
                
                <div class="form-group">
                    <label for="projects_0_startDate">Start Date</label>
                    <input type="date" id="projects_0_startDate" name="projects[0][startDate]">
                </div>
                
                <div class="form-group">
                    <label for="projects_0_endDate">End Date</label>
                    <input type="date" id="projects_0_endDate" name="projects[0][endDate]">
                </div>
                
                <div class="form-group">
                    <label for="projects_0_description">Description</label>
                    <textarea id="projects_0_description" name="projects[0][description]"></textarea>
                </div>
                
                <!-- Highlights Array -->
                <div id="project-highlights-container-0">
                    <legend>Highlights</legend>
                    <button type="button" class="add-btn" onclick="addProjectHighlight(0)">+ Add Highlight</button>
                    <div class="array-item">
                        <div class="form-group">
                            <label for="projects_0_highlights_0">Highlight</label>
                            <input type="text" id="projects_0_highlights_0" name="projects[0][highlights][0]">
                        </div>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="projects_0_url">Project URL</label>
                    <input type="url" id="projects_0_url" name="projects[0][url]">
                </div>
            </div>
        </fieldset>
        
        <div class="form-group">
            <button type="submit">Submit</button>
            <button type="reset">Reset</button>
        </div>
    </form>

    <script>
        // Counter variables for each array type
        let profileCount = 1;
        let workCount = 1;
        let volunteerCount = 1;
        let educationCount = 1;
        let awardCount = 1;
        let certificateCount = 1;
        let publicationCount = 1;
        let skillCount = 1;
        let languageCount = 1;
        let interestCount = 1;
        let referenceCount = 1;
        let projectCount = 1;
        
        // Function to add a new profile
        function addProfile() {
            const container = document.getElementById('profiles-container');
            const newProfile = document.createElement('div');
            newProfile.className = 'array-item';
            newProfile.id = `profile-${profileCount}`;
            
            newProfile.innerHTML = `
                <button type="button" class="remove-btn" onclick="removeItem('profile-${profileCount}')">×</button>
                <div class="form-group">
                    <label for="basics_profiles_${profileCount}_network">Network</label>
                    <input type="text" id="basics_profiles_${profileCount}_network" name="basics[profiles][${profileCount}][network]">
                </div>
                
                <div class="form-group">
                    <label for="basics_profiles_${profileCount}_username">Username</label>
                    <input type="text" id="basics_profiles_${profileCount}_username" name="basics[profiles][${profileCount}][username]">
                </div>
                
                <div class="form-group">
                    <label for="basics_profiles_${profileCount}_url">Profile URL</label>
                    <input type="url" id="basics_profiles_${profileCount}_url" name="basics[profiles][${profileCount}][url]">
                </div>
            `;
            
            container.appendChild(newProfile);
            profileCount++;
        }
        
        // Function to add a new work experience
        function addWork() {
            const container = document.getElementById('work-container');
            const newWork = document.createElement('div');
            newWork.className = 'array-item';
            newWork.id = `work-${workCount}`;
            
            newWork.innerHTML = `
                <button type="button" class="remove-btn" onclick="removeItem('work-${workCount}')">×</button>
                <div class="form-group">
                    <label for="work_${workCount}_name">Company Name</label>
                    <input type="text" id="work_${workCount}_name" name="work[${workCount}][name]">
                </div>
                
                <div class="form-group">
                    <label for="work_${workCount}_position">Position</label>
                    <input type="text" id="work_${workCount}_position" name="work[${workCount}][position]">
                </div>
                
                <div class="form-group">
                    <label for="work_${workCount}_url">Company URL</label>
                    <input type="url" id="work_${workCount}_url" name="work[${workCount}][url]">
                </div>
                
                <div class="form-group">
                    <label for="work_${workCount}_startDate">Start Date</label>
                    <input type="date" id="work_${workCount}_startDate" name="work[${workCount}][startDate]">
                </div>
                
                <div class="form-group">
                    <label for="work_${workCount}_endDate">End Date</label>
                    <input type="date" id="work_${workCount}_endDate" name="work[${workCount}][endDate]">
                </div>
                
                <div class="form-group">
                    <label for="work_${workCount}_summary">Summary</label>
                    <textarea id="work_${workCount}_summary" name="work[${workCount}][summary]"></textarea>
                </div>
                
                <div id="work-highlights-container-${workCount}">
                    <legend>Highlights</legend>
                    <button type="button" class="add-btn" onclick="addWorkHighlight(${workCount})">+ Add Highlight</button>
                    <div class="array-item">
                        <div class="form-group">
                            <label for="work_${workCount}_highlights_0">Highlight</label>
                            <input type="text" id="work_${workCount}_highlights_0" name="work[${workCount}][highlights][0]">
                        </div>
                    </div>
                </div>
            `;
            
            container.appendChild(newWork);
            workCount++;
        }
        
        // Function to add a highlight to a work experience
        function addWorkHighlight(workIndex) {
            const container = document.getElementById(`work-highlights-container-${workIndex}`);
            const highlightCount = container.querySelectorAll('.array-item').length;
            
            const newHighlight = document.createElement('div');
            newHighlight.className = 'array-item';
            
            newHighlight.innerHTML = `
                <button type="button" class="remove-btn" onclick="this.parentNode.remove()">×</button>
                <div class="form-group">
                    <label for="work_${workIndex}_highlights_${highlightCount}">Highlight</label>
                    <input type="text" id="work_${workIndex}_highlights_${highlightCount}" name="work[${workIndex}][highlights][${highlightCount}]">
                </div>
            `;
            
            container.appendChild(newHighlight);
        }
        
        // Function to add a new volunteer experience
        function addVolunteer() {
            const container = document.getElementById('volunteer-container');
            const newVolunteer = document.createElement('div');
            newVolunteer.className = 'array-item';
            newVolunteer.id = `volunteer-${volunteerCount}`;
            
            newVolunteer.innerHTML = `
                <button type="button" class="remove-btn" onclick="removeItem('volunteer-${volunteerCount}')">×</button>
                <div class="form-group">
                    <label for="volunteer_${volunteerCount}_organization">Organization</label>
                    <input type="text" id="volunteer_${volunteerCount}_organization" name="volunteer[${volunteerCount}][organization]">
                </div>
                
                <div class="form-group">
                    <label for="volunteer_${volunteerCount}_position">Position</label>
                    <input type="text" id="volunteer_${volunteerCount}_position" name="volunteer[${volunteerCount}][position]">
                </div>
                
                <div class="form-group">
                    <label for="volunteer_${volunteerCount}_url">Organization URL</label>
                    <input type="url" id="volunteer_${volunteerCount}_url" name="volunteer[${volunteerCount}][url]">
                </div>
                
                <div class="form-group">
                    <label for="volunteer_${volunteerCount}_startDate">Start Date</label>
                    <input type="date" id="volunteer_${volunteerCount}_startDate" name="volunteer[${volunteerCount}][startDate]">
                </div>
                
                <div class="form-group">
                    <label for="volunteer_${volunteerCount}_endDate">End Date</label>
                    <input type="date" id="volunteer_${volunteerCount}_endDate" name="volunteer[${volunteerCount}][endDate]">
                </div>
                
                <div class="form-group">
                    <label for="volunteer_${volunteerCount}_summary">Summary</label>
                    <textarea id="volunteer_${volunteerCount}_summary" name="volunteer[${volunteerCount}][summary]"></textarea>
                </div>
                
                <div id="volunteer-highlights-container-${volunteerCount}">
                    <legend>Highlights</legend>
                    <button type="button" class="add-btn" onclick="addVolunteerHighlight(${volunteerCount})">+ Add Highlight</button>
                    <div class="array-item">
                        <div class="form-group">
                            <label for="volunteer_${volunteerCount}_highlights_0">Highlight</label>
                            <input type="text" id="volunteer_${volunteerCount}_highlights_0" name="volunteer[${volunteerCount}][highlights][0]">
                        </div>
                    </div>
                </div>
            `;
            
            container.appendChild(newVolunteer);
            volunteerCount++;
        }
        
        // Function to add a highlight to a volunteer experience
        function addVolunteerHighlight(volunteerIndex) {
            const container = document.getElementById(`volunteer-highlights-container-${volunteerIndex}`);
            const highlightCount = container.querySelectorAll('.array-item').length;
            
            const newHighlight = document.createElement('div');
            newHighlight.className = 'array-item';
            
            newHighlight.innerHTML = `
                <button type="button" class="remove-btn" onclick="this.parentNode.remove()">×</button>
                <div class="form-group">
                    <label for="volunteer_${volunteerIndex}_highlights_${highlightCount}">Highlight</label>
                    <input type="text" id="volunteer_${volunteerIndex}_highlights_${highlightCount}" name="volunteer[${volunteerIndex}][highlights][${highlightCount}]">
                </div>
            `;
            
            container.appendChild(newHighlight);
        }
        
        // Function to add a new education entry
        function addEducation() {
            const container = document.getElementById('education-container');
            const newEducation = document.createElement('div');
            newEducation.className = 'array-item';
            newEducation.id = `education-${educationCount}`;
            
            newEducation.innerHTML = `
                <button type="button" class="remove-btn" onclick="removeItem('education-${educationCount}')">×</button>
                <div class="form-group">
                    <label for="education_${educationCount}_institution">Institution</label>
                    <input type="text" id="education_${educationCount}_institution" name="education[${educationCount}][institution]">
                </div>
                
                <div class="form-group">
                    <label for="education_${educationCount}_url">Institution URL</label>
                    <input type="url" id="education_${educationCount}_url" name="education[${educationCount}][url]">
                </div>
                
                <div class="form-group">
                    <label for="education_${educationCount}_area">Area of Study</label>
                    <input type="text" id="education_${educationCount}_area" name="education[${educationCount}][area]">
                </div>
                
                <div class="form-group">
                    <label for="education_${educationCount}_studyType">Degree Type</label>
                    <input type="text" id="education_${educationCount}_studyType" name="education[${educationCount}][studyType]">
                </div>
                
                <div class="form-group">
                    <label for="education_${educationCount}_startDate">Start Date</label>
                    <input type="date" id="education_${educationCount}_startDate" name="education[${educationCount}][startDate]">
                </div>
                
                <div class="form-group">
                    <label for="education_${educationCount}_endDate">End Date</label>
                    <input type="date" id="education_${educationCount}_endDate" name="education[${educationCount}][endDate]">
                </div>
                
                <div class="form-group">
                    <label for="education_${educationCount}_score">GPA/Score</label>
                    <input type="text" id="education_${educationCount}_score" name="education[${educationCount}][score]">
                </div>
                
                <div id="education-courses-container-${educationCount}">
                    <legend>Courses</legend>
                    <button type="button" class="add-btn" onclick="addCourse(${educationCount})">+ Add Course</button>
                    <div class="array-item">
                        <div class="form-group">
                            <label for="education_${educationCount}_courses_0">Course</label>
                            <input type="text" id="education_${educationCount}_courses_0" name="education[${educationCount}][courses][0]">
                        </div>
                    </div>
                </div>
            `;
            
            container.appendChild(newEducation);
            educationCount++;
        }
        
        // Function to add a course to an education entry
        function addCourse(educationIndex) {
            const container = document.getElementById(`education-courses-container-${educationIndex}`);
            const courseCount = container.querySelectorAll('.array-item').length;
            
            const newCourse = document.createElement('div');
            newCourse.className = 'array-item';
            
            newCourse.innerHTML = `
                <button type="button" class="remove-btn" onclick="this.parentNode.remove()">×</button>
                <div class="form-group">
                    <label for="education_${educationIndex}_courses_${courseCount}">Course</label>
                    <input type="text" id="education_${educationIndex}_courses_${courseCount}" name="education[${educationIndex}][courses][${courseCount}]">
                </div>
            `;
            
            container.appendChild(newCourse);
        }
        
        // Function to add a new award
        function addAward() {
            const container = document.getElementById('awards-container');
            const newAward = document.createElement('div');
            newAward.className = 'array-item';
            newAward.id = `award-${awardCount}`;
            
            newAward.innerHTML = `
                <button type="button" class="remove-btn" onclick="removeItem('award-${awardCount}')">×</button>
                <div class="form-group">
                    <label for="awards_${awardCount}_title">Title</label>
                    <input type="text" id="awards_${awardCount}_title" name="awards[${awardCount}][title]">
                </div>
                
                <div class="form-group">
                    <label for="awards_${awardCount}_date">Date</label>
                    <input type="date" id="awards_${awardCount}_date" name="awards[${awardCount}][date]">
                </div>
                
                <div class="form-group">
                    <label for="awards_${awardCount}_awarder">Awarder</label>
                    <input type="text" id="awards_${awardCount}_awarder" name="awards[${awardCount}][awarder]">
                </div>
                
                <div class="form-group">
                    <label for="awards_${awardCount}_summary">Summary</label>
                    <textarea id="awards_${awardCount}_summary" name="awards[${awardCount}][summary]"></textarea>
                </div>
            `;
            
            container.appendChild(newAward);
            awardCount++;
        }
        
        // Function to add a new certificate
        function addCertificate() {
            const container = document.getElementById('certificates-container');
            const newCertificate = document.createElement('div');
            newCertificate.className = 'array-item';
            newCertificate.id = `certificate-${certificateCount}`;
            
            newCertificate.innerHTML = `
                <button type="button" class="remove-btn" onclick="removeItem('certificate-${certificateCount}')">×</button>
                <div class="form-group">
                    <label for="certificates_${certificateCount}_name">Name</label>
                    <input type="text" id="certificates_${certificateCount}_name" name="certificates[${certificateCount}][name]">
                </div>
                
                <div class="form-group">
                    <label for="certificates_${certificateCount}_date">Date</label>
                    <input type="date" id="certificates_${certificateCount}_date" name="certificates[${certificateCount}][date]">
                </div>
                
                <div class="form-group">
                    <label for="certificates_${certificateCount}_issuer">Issuer</label>
                    <input type="text" id="certificates_${certificateCount}_issuer" name="certificates[${certificateCount}][issuer]">
                </div>
                
                <div class="form-group">
                    <label for="certificates_${certificateCount}_url">Certificate URL</label>
                    <input type="url" id="certificates_${certificateCount}_url" name="certificates[${certificateCount}][url]">
                </div>
            `;
            
            container.appendChild(newCertificate);
            certificateCount++;
        }
        
        // Function to add a new publication
        function addPublication() {
            const container = document.getElementById('publications-container');
            const newPublication = document.createElement('div');
            newPublication.className = 'array-item';
            newPublication.id = `publication-${publicationCount}`;
            
            newPublication.innerHTML = `
                <button type="button" class="remove-btn" onclick="removeItem('publication-${publicationCount}')">×</button>
                <div class="form-group">
                    <label for="publications_${publicationCount}_name">Name</label>
                    <input type="text" id="publications_${publicationCount}_name" name="publications[${publicationCount}][name]">
                </div>
                
                <div class="form-group">
                    <label for="publications_${publicationCount}_publisher">Publisher</label>
                    <input type="text" id="publications_${publicationCount}_publisher" name="publications[${publicationCount}][publisher]">
                </div>
                
                <div class="form-group">
                    <label for="publications_${publicationCount}_releaseDate">Release Date</label>
                    <input type="date" id="publications_${publicationCount}_releaseDate" name="publications[${publicationCount}][releaseDate]">
                </div>
                
                <div class="form-group">
                    <label for="publications_${publicationCount}_url">Publication URL</label>
                    <input type="url" id="publications_${publicationCount}_url" name="publications[${publicationCount}][url]">
                </div>
                
                <div class="form-group">
                    <label for="publications_${publicationCount}_summary">Summary</label>
                    <textarea id="publications_${publicationCount}_summary" name="publications[${publicationCount}][summary]"></textarea>
                </div>
            `;
            
            container.appendChild(newPublication);
            publicationCount++;
        }
        
        // Function to add a new skill
        function addSkill() {
            const container = document.getElementById('skills-container');
            const newSkill = document.createElement('div');
            newSkill.className = 'array-item';
            newSkill.id = `skill-${skillCount}`;
            
            newSkill.innerHTML = `
                <button type="button" class="remove-btn" onclick="removeItem('skill-${skillCount}')">×</button>
                <div class="form-group">
                    <label for="skills_${skillCount}_name">Skill Name</label>
                    <input type="text" id="skills_${skillCount}_name" name="skills[${skillCount}][name]">
                </div>
                
                <div class="form-group">
                    <label for="skills_${skillCount}_level">Level</label>
                    <select id="skills_${skillCount}_level" name="skills[${skillCount}][level]">
                        <option value="">Select level</option>
                        <option value="Beginner">Beginner</option>
                        <option value="Intermediate">Intermediate</option>
                        <option value="Advanced">Advanced</option>
                        <option value="Master">Master</option>
                    </select>
                </div>
                
                <div id="skill-keywords-container-${skillCount}">
                    <legend>Keywords</legend>
                    <button type="button" class="add-btn" onclick="addSkillKeyword(${skillCount})">+ Add Keyword</button>
                    <div class="array-item">
                        <div class="form-group">
                            <label for="skills_${skillCount}_keywords_0">Keyword</label>
                            <input type="text" id="skills_${skillCount}_keywords_0" name="skills[${skillCount}][keywords][0]">
                        </div>
                    </div>
                </div>
            `;
            
            container.appendChild(newSkill);
            skillCount++;
        }
        
        // Function to add a keyword to a skill
        function addSkillKeyword(skillIndex) {
            const container = document.getElementById(`skill-keywords-container-${skillIndex}`);
            const keywordCount = container.querySelectorAll('.array-item').length;
            
            const newKeyword = document.createElement('div');
            newKeyword.className = 'array-item';
            
            newKeyword.innerHTML = `
                <button type="button" class="remove-btn" onclick="this.parentNode.remove()">×</button>
                <div class="form-group">
                    <label for="skills_${skillIndex}_keywords_${keywordCount}">Keyword</label>
                    <input type="text" id="skills_${skillIndex}_keywords_${keywordCount}" name="skills[${skillIndex}][keywords][${keywordCount}]">
                </div>
            `;
            
            container.appendChild(newKeyword);
        }
        
        // Function to add a new language
        function addLanguage() {
            const container = document.getElementById('languages-container');
            const newLanguage = document.createElement('div');
            newLanguage.className = 'array-item';
            newLanguage.id = `language-${languageCount}`;
            
            newLanguage.innerHTML = `
                <button type="button" class="remove-btn" onclick="removeItem('language-${languageCount}')">×</button>
                <div class="form-group">
                    <label for="languages_${languageCount}_language">Language</label>
                    <input type="text" id="languages_${languageCount}_language" name="languages[${languageCount}][language]">
                </div>
                
                <div class="form-group">
                    <label for="languages_${languageCount}_fluency">Fluency</label>
                    <input type="text" id="languages_${languageCount}_fluency" name="languages[${languageCount}][fluency]">
                </div>
            `;
            
            container.appendChild(newLanguage);
            languageCount++;
        }
        
        // Function to add a new interest
        function addInterest() {
            const container = document.getElementById('interests-container');
            const newInterest = document.createElement('div');
            newInterest.className = 'array-item';
            newInterest.id = `interest-${interestCount}`;
            
            newInterest.innerHTML = `
                <button type="button" class="remove-btn" onclick="removeItem('interest-${interestCount}')">×</button>
                <div class="form-group">
                    <label for="interests_${interestCount}_name">Interest Name</label>
                    <input type="text" id="interests_${interestCount}_name" name="interests[${interestCount}][name]">
                </div>
                
                <div id="interest-keywords-container-${interestCount}">
                    <legend>Keywords</legend>
                    <button type="button" class="add-btn" onclick="addInterestKeyword(${interestCount})">+ Add Keyword</button>
                    <div class="array-item">
                        <div class="form-group">
                            <label for="interests_${interestCount}_keywords_0">Keyword</label>
                            <input type="text" id="interests_${interestCount}_keywords_0" name="interests[${interestCount}][keywords][0]">
                        </div>
                    </div>
                </div>
            `;
            
            container.appendChild(newInterest);
            interestCount++;
        }
        
        // Function to add a keyword to an interest
        function addInterestKeyword(interestIndex) {
            const container = document.getElementById(`interest-keywords-container-${interestIndex}`);
            const keywordCount = container.querySelectorAll('.array-item').length;
            
            const newKeyword = document.createElement('div');
            newKeyword.className = 'array-item';
            
            newKeyword.innerHTML = `
                <button type="button" class="remove-btn" onclick="this.parentNode.remove()">×</button>
                <div class="form-group">
                    <label for="interests_${interestIndex}_keywords_${keywordCount}">Keyword</label>
                    <input type="text" id="interests_${interestIndex}_keywords_${keywordCount}" name="interests[${interestIndex}][keywords][${keywordCount}]">
                </div>
            `;
            
            container.appendChild(newKeyword);
        }
        
        // Function to add a new reference
        function addReference() {
            const container = document.getElementById('references-container');
            const newReference = document.createElement('div');
            newReference.className = 'array-item';
            newReference.id = `reference-${referenceCount}`;
            
            newReference.innerHTML = `
                <button type="button" class="remove-btn" onclick="removeItem('reference-${referenceCount}')">×</button>
                <div class="form-group">
                    <label for="references_${referenceCount}_name">Name</label>
                    <input type="text" id="references_${referenceCount}_name" name="references[${referenceCount}][name]">
                </div>
                
                <div class="form-group">
                    <label for="references_${referenceCount}_reference">Reference</label>
                    <textarea id="references_${referenceCount}_reference" name="references[${referenceCount}][reference]"></textarea>
                </div>
            `;
            
            container.appendChild(newReference);
            referenceCount++;
        }
        
        // Function to add a new project
        function addProject() {
            const container = document.getElementById('projects-container');
            const newProject = document.createElement('div');
            newProject.className = 'array-item';
            newProject.id = `project-${projectCount}`;
            
            newProject.innerHTML = `
                <button type="button" class="remove-btn" onclick="removeItem('project-${projectCount}')">×</button>
                <div class="form-group">
                    <label for="projects_${projectCount}_name">Project Name</label>
                    <input type="text" id="projects_${projectCount}_name" name="projects[${projectCount}][name]">
                </div>
                
                <div class="form-group">
                    <label for="projects_${projectCount}_startDate">Start Date</label>
                    <input type="date" id="projects_${projectCount}_startDate" name="projects[${projectCount}][startDate]">
                </div>
                
                <div class="form-group">
                    <label for="projects_${projectCount}_endDate">End Date</label>
                    <input type="date" id="projects_${projectCount}_endDate" name="projects[${projectCount}][endDate]">
                </div>
                
                <div class="form-group">
                    <label for="projects_${projectCount}_description">Description</label>
                    <textarea id="projects_${projectCount}_description" name="projects[${projectCount}][description]"></textarea>
                </div>
                
                <div id="project-highlights-container-${projectCount}">
                    <legend>Highlights</legend>
                    <button type="button" class="add-btn" onclick="addProjectHighlight(${projectCount})">+ Add Highlight</button>
                    <div class="array-item">
                        <div class="form-group">
                            <label for="projects_${projectCount}_highlights_0">Highlight</label>
                            <input type="text" id="projects_${projectCount}_highlights_0" name="projects[${projectCount}][highlights][0]">
                        </div>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="projects_${projectCount}_url">Project URL</label>
                    <input type="url" id="projects_${projectCount}_url" name="projects[${projectCount}][url]">
                </div>
            `;
            
            container.appendChild(newProject);
            projectCount++;
        }
        
        // Function to add a highlight to a project
        function addProjectHighlight(projectIndex) {
            const container = document.getElementById(`project-highlights-container-${projectIndex}`);
            const highlightCount = container.querySelectorAll('.array-item').length;
            
            const newHighlight = document.createElement('div');
            newHighlight.className = 'array-item';
            
            newHighlight.innerHTML = `
                <button type="button" class="remove-btn" onclick="this.parentNode.remove()">×</button>
                <div class="form-group">
                    <label for="projects_${projectIndex}_highlights_${highlightCount}">Highlight</label>
                    <input type="text" id="projects_${projectIndex}_highlights_${highlightCount}" name="projects[${projectIndex}][highlights][${highlightCount}]">
                </div>
            `;
            
            container.appendChild(newHighlight);
        }
        
        // Function to remove an item
        function removeItem(id) {
            const element = document.getElementById(id);
            if (element) {
                element.remove();
            }
        }
    </script>
</body>
</html>''';
}

String getResumeHtml() {
  return r'''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>{{ basics.name }} - Resume</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      padding: 20px;
      background: #f4f4f4;
    }
    h1, h2, h3 {
      color: #333;
    }
    section {
      margin-bottom: 30px;
      padding: 20px;
      background: white;
      border-radius: 8px;
      box-shadow: 0 0 10px rgba(0,0,0,0.1);
    }
    ul {
      margin-top: 0;
    }
  </style>
</head>
<body>

  <section>
    <h1>{{ basics.name }}</h1>
    <h3>{{ basics.label }}</h3>
    <p><strong>Email:</strong> {{ basics.email }}</p>
    <p><strong>Phone:</strong> {{ basics.phone }}</p>
    <p><strong>Website:</strong> <a href="{{ basics.url }}">{{ basics.url }}</a></p>
    <p><strong>Summary:</strong> {{ basics.summary }}</p>
    <p><strong>Location:</strong> {{ basics.location.address }}, {{ basics.location.city }}, {{ basics.location.region }}, {{ basics.location.countryCode }} - {{ basics.location.postalCode }}</p>

    {% if basics.profiles %}
      <h4>Profiles</h4>
      <ul>
        {% for profile in basics.profiles %}
          <li>{{ profile.network }} - <a href="{{ profile.url }}">{{ profile.username }}</a></li>
        {% endfor %}
      </ul>
    {% endif %}
  </section>

  {% if work %}
  <section>
    <h2>Work Experience</h2>
    {% for job in work %}
      <h3>{{ job.position }} @ {{ job.name }}</h3>
      <p>{{ job.startDate }} to {{ job.endDate }}</p>
      <p>{{ job.summary }}</p>
      <ul>
        {% for highlight in job.highlights %}
          <li>{{ highlight }}</li>
        {% endfor %}
      </ul>
    {% endfor %}
  </section>
  {% endif %}

  {% if volunteer %}
  <section>
    <h2>Volunteer Work</h2>
    {% for v in volunteer %}
      <h3>{{ v.position }} @ {{ v.organization }}</h3>
      <p>{{ v.startDate }} to {{ v.endDate }}</p>
      <p>{{ v.summary }}</p>
      <ul>
        {% for highlight in v.highlights %}
          <li>{{ highlight }}</li>
        {% endfor %}
      </ul>
    {% endfor %}
  </section>
  {% endif %}

  {% if education %}
  <section>
    <h2>Education</h2>
    {% for edu in education %}
      <h3>{{ edu.studyType }} in {{ edu.area }} @ {{ edu.institution }}</h3>
      <p>{{ edu.startDate }} to {{ edu.endDate }} - GPA: {{ edu.score }}</p>
      <ul>
        {% for course in edu.courses %}
          <li>{{ course }}</li>
        {% endfor %}
      </ul>
    {% endfor %}
  </section>
  {% endif %}

  {% if awards %}
  <section>
    <h2>Awards</h2>
    {% for award in awards %}
      <h3>{{ award.title }} - {{ award.awarder }}</h3>
      <p>{{ award.date }}</p>
      <p>{{ award.summary }}</p>
    {% endfor %}
  </section>
  {% endif %}

  {% if certificates %}
  <section>
    <h2>Certificates</h2>
    {% for cert in certificates %}
      <h3>{{ cert.name }}</h3>
      <p>{{ cert.date }} - Issued by {{ cert.issuer }}</p>
      <p><a href="{{ cert.url }}">{{ cert.url }}</a></p>
    {% endfor %}
  </section>
  {% endif %}

  {% if publications %}
  <section>
    <h2>Publications</h2>
    {% for pub in publications %}
      <h3>{{ pub.name }}</h3>
      <p>{{ pub.publisher }} - {{ pub.releaseDate }}</p>
      <p>{{ pub.summary }}</p>
      <p><a href="{{ pub.url }}">{{ pub.url }}</a></p>
    {% endfor %}
  </section>
  {% endif %}

  {% if skills %}
  <section>
    <h2>Skills</h2>
    {% for skill in skills %}
      <h3>{{ skill.name }} ({{ skill.level }})</h3>
      <ul>
        {% for keyword in skill.keywords %}
          <li>{{ keyword }}</li>
        {% endfor %}
      </ul>
    {% endfor %}
  </section>
  {% endif %}

  {% if languages %}
  <section>
    <h2>Languages</h2>
    {% for lang in languages %}
      <p>{{ lang.language }} - {{ lang.fluency }}</p>
    {% endfor %}
  </section>
  {% endif %}

  {% if interests %}
  <section>
    <h2>Interests</h2>
    {% for interest in interests %}
      <h4>{{ interest.name }}</h4>
      <ul>
        {% for keyword in interest.keywords %}
          <li>{{ keyword }}</li>
        {% endfor %}
      </ul>
    {% endfor %}
  </section>
  {% endif %}

  {% if references %}
  <section>
    <h2>References</h2>
    {% for ref in references %}
      <h4>{{ ref.name }}</h4>
      <p>{{ ref.reference }}</p>
    {% endfor %}
  </section>
  {% endif %}

  {% if projects %}
  <section>
    <h2>Projects</h2>
    {% for project in projects %}
      <h3>{{ project.name }}</h3>
      <p>{{ project.startDate }} to {{ project.endDate }}</p>
      <p>{{ project.description }}</p>
      <ul>
        {% for highlight in project.highlights %}
          <li>{{ highlight }}</li>
        {% endfor %}
      </ul>
      <p><a href="{{ project.url }}">{{ project.url }}</a></p>
    {% endfor %}
  </section>
  {% endif %}

</body>
</html>
''';
}

String getResumeHtml1() {
  return r'''<html lang="en">
<head>
<meta charset="UTF-8">
<title>Resume for {{ basics.name }}</title>
<meta http-equiv="Generator" content="jsonresume-theme-rickosborne">
<style>
@import url('https://fonts.googleapis.com/css2?family=Roboto+Slab:wght@200;400&display=swap');
body {
    font-family: 'Roboto Slab', 'Gentium Book Basic', 'Gentium Plus', 'Gentium Basic', 'Times New Roman', 'Times', ui-serif, serif;
}
</style>
<style>:root {
    --text: 1.92vw;
    --cadence-quarter: calc(var(--text) * 0.45);
    --cadence-half: calc(var(--text) * 0.9);
    --cadence-one: calc(var(--text) * 1.8);
    --cadence-two: calc(var(--text) * 3.6);
    --text-color: #222;
    --light: #444;
    --lighter: #666;
    --ghostly: #eee;
}

html {
    width: 100%;
    height: 100%;
    background: #555;
    margin: 0;
    padding: 0;
    font-size: var(--text);
}

* {
    margin: 0;
    padding: 0;
    outline: none;
    text-indent: 0;
    list-style: none;
    font-weight: 200;
    font-style: normal;
    text-decoration: none;
}

body, h1, h2, h3, h4, h5, h6 {
    font-size: var(--text);
}

body {
    width: 100%;
    min-height: 100%;
    overflow-y: auto;
    background: white;
    color: var(--text-color);
    max-width: calc(var(--text) * 50.0);
    margin: var(--cadence-half) auto;
    padding: 0;
    box-shadow: 0 0 var(--cadence-half) black;
    line-height: var(--cadence-one);
}

a, a:visited, a:focus, a:hover {
    color: #248 !important;
    text-decoration: none;
}

a:focus, a:hover {
    color: #36c !important;
    text-decoration: underline;
}

#resume {
    padding: var(--cadence-one);
    align-content: start;
    align-items: start;
    display: flex;
    flex-wrap: wrap;
    flex-direction: row;
}

#basics {
    display: grid;
    grid-template-areas:
        "name label"
        "summary summary";
    grid-template-columns: 1fr auto;
    align-items: baseline;
    gap: 0;
}

#person-name {
    font-size: 200%;
    line-height: var(--cadence-two);
    grid-area: name;
    flex-wrap: nowrap;
    white-space: nowrap;
    flex-grow: 1;
}

#person-label {
    font-size: 150%;
    line-height: var(--cadence-two);
    grid-area: label;
    color: var(--light);
}

#person-summary {
    grid-area: summary;
    color: var(--lighter);
    font-style: italic;
}

.has-image #top {
    display: flex;
    flex-direction: row;
}

.has-image #basics {
    display: block;
}

.has-image #person-name {
    line-height: inherit;
    margin-bottom: var(--cadence-quarter);
}

.has-image #person-label {
    line-height: inherit;
    font-size: 120%;
    margin-bottom: var(--cadence-quarter);
}

.has-image #person-summary {
    line-height: 120%;
}

.person-location-parts {
    display: flex;
    flex-direction: row;
    flex-wrap: wrap;
    gap: 0 var(--cadence-quarter);
}

// #avatar {
//     max-width: 60%;
//     padding: 0 20%;
//     height: auto;
//     border-radius: 50%;
//     margin-bottom: var(--cadence-half);
// }
#avatar {
  max-width: 70%;
  aspect-ratio: 1 / 1;
  width: auto;
  height: auto;
  padding: 5% 5%;
  border-radius: 50%;
  margin-bottom: var(--cadence-half);
  object-fit: cover;
  display: block;
}

#top {
    flex-basis: 100%;
    order: 1;
}

#left {
    padding-right: var(--cadence-one);
    grid-area: left;
    min-width: 60%;
    flex-basis: 60%;
    order: 2;
    flex-grow: 1;
    flex-shrink: 0;
}

#right {
    padding-left: var(--cadence-one);
    grid-area: right;
    min-width: 30%;
    flex-basis: 30%;
    order: 3;
    flex-grow: 0;
    flex-shrink: 0;
}

#right, #right h1, #right h2, #right h3, #right h4, #right h5, #right h6 {
    font-size: 90%;
}

.list h1 {
    font-weight: 400;
    text-transform: uppercase;
    color: var(--lighter);
    line-height: var(--cadence-two);
}

.list {
    margin-bottom: 0;
}

.list header {
    color: var(--lighter);
}

.list header > *:first-child {
    color: var(--text-color);
}

.list header > * {
    display: inline;
}

.list header .between:after, .language-item .between:after, .person-location-parts .between:after {
    content: ",\20";
    color: var(--lighter);
}

#right .list header > *:first-child, .list header > *:first-child {
    padding-left: 0;
    border-left: none;
    margin-left: 0;
}

#right .list header > *:last-child:after, .list header > *:last-child:after {
    content: none;
    padding-right: unset;
}

.list header > *:first-child {
    font-weight: 400;
}

.dates {
    display: flex;
    flex-direction: row;
    flex-wrap: nowrap;
}

.date-delimiter::before {
    content: "-";
}

.dates {
    break-inside: avoid;
    white-space: nowrap;
}

.dates.same-dates .date-start,
.dates.same-dates .date-delimiter,
.dates.no-start .date-delimiter,
.dates.no-end .date-delimiter {
    display: none;
}

.education-summary, .work-summary, .project-description {
    font-style: italic;
}

.work-domain, .work-location, .work-employer {
    letter-spacing: -0.05em;
    color: var(--lighter);
}

.work-item {
    margin-bottom: var(--cadence-half);
}

.work-highlights-list {
    margin-left: var(--cadence-one);
}

.work-highlights-item {
    list-style-type: square;
}

.work-highlights-item ::marker {
    color: var(--light);
}

.work-highlights-item .first-word {
    font-style: italic;
}

.skill-item, .interest-item {
    margin: var(--cadence-quarter) 0;
}

.skill-item header, .interest-item header {
    line-height: 120%;
}

.skill-item:first-of-type, .interest-item:first-of-type {
    margin-top: 0;
}

.skill-keyword-list, .interest-keyword-list {
    display: flex;
    flex-direction: row;
    flex-wrap: wrap;
    gap: calc(var(--cadence-quarter) * 0.5);
}

.skill-keyword-item, .interest-keyword-item {
    background-color: var(--ghostly);
    color: var(--light);
    border-radius: var(--cadence-quarter);
    padding: calc(var(--cadence-quarter) * 0.5) var(--cadence-quarter);
    font-size: 90%;
    line-height: 90%;
    text-wrap: avoid;
    white-space: nowrap;
}

.skill-level {
    color: var(--lighter);
    font-size: 90%;
    margin: var(--cadence-quarter);
}

#top {
    grid-area: top;
}

#bottom {
    grid-area: bottom;
}

#person-url, #person-email, #person-phone, #person-location, .profile-url {
    display: flex;
    flex-direction: row;
    gap: var(--cadence-quarter);
    align-items: start;
    align-content: start;
}

.icon {
    width: calc(var(--cadence-one) * 0.8);
    height: calc(var(--cadence-one) * 0.8);
    opacity: 25%;
    flex-shrink: 0;
    flex-grow: 0;
    padding: calc(var(--cadence-one) * 0.1);
    padding-left: 0;
}

#basics-profiles, #basics-contact, #basics-url, #basics-email, #basics-location, .profile-network {
    display: none;
}

#person-location .between {
    width: 0;
    margin-left: calc(var(--cadence-quarter) * -1.0);
}

.project-item header {
    line-height: 120%;
}

.project-url-a, .project-description {
    font-size: 90%;
    line-height: 120%;
}

.project-description {
    margin-top: var(--cadence-quarter);
}

.project-item {
    margin-bottom: var(--cadence-quarter);
}

@media print {
    :root {
        --text: 8.75pt;
        --cadence-quarter: calc(var(--text) * 0.4);
        --cadence-half: calc(var(--text) * 0.8);
        --cadence-one: calc(var(--text) * 1.6);
        --cadence-two: calc(var(--text) * 3.2);
    }

    html {
        background-color: transparent;
    }

    body {
        box-shadow: none;
        width: 100%;
        max-width: 100%;
        padding: 0;
        margin: 0 auto;
        line-height: 130%;
        break-inside: auto;
        page-break-inside: auto;
    }

    a, a:visited, a:focus, a:hover {
        color: var(--text-color) !important;
    }

    .no-print {
        display: none;
    }

    #resume {
        padding: 0;
        margin: 0;
    }

    #top {
        page-break-after: avoid;
        break-after: avoid;
    }

    #left, #right, #resume {
        break-before: avoid;
        page-break-before: avoid;
        break-inside: auto;
        page-break-inside: auto;
    }

    #bottom {
        page-break-before: avoid;
        break-before: avoid;
    }

    #right {
        padding-top: var(--cadence-half);
    }

    #left > section, #right > section {
        break-before: avoid;
        break-inside: auto;
        page-break-before: avoid;
        page-break-inside: auto;
    }

    .work-highlights-item {
        font-size: 90%;
        line-height: 120%;
    }

    #person-summary, .list h1 {
        color: var(--light);
    }
}

@media print and (-webkit-min-device-pixel-ratio:0) {
    /* Safari */
    .work-item {
        margin-bottom: var(--cadence-quarter);
    }
    #resume {
        padding-top: var(--cadence-quarter);
    }
}

@media screen {
    #how-to-print {
        position: fixed;
        bottom: 0;
        right: 0;
        width: calc(var(--cadence-half) + 30%);
        background-color: hsla(60, 100%, 80%, 95%);
        padding: var(--cadence-quarter);
        font-size: 80%;
        border-top: thin solid hsla(60, 100%, 40%, 95%);
        border-left: thin solid hsla(60, 100%, 40%, 95%);
        line-height: 120%;
    }
}
.xdoc-editable:focus {
  outline: 2px solid blue;
}
</style>
</head>
<body class="has-image">
<article id="resume">

<section id="left" class=" ">
    <header id="basics">
        <h1 id="person-name" class="xdoc-editable xdoc-label-name">{{ basics.name }}</h1>
        {% if basics.label %}
        <span class="between"></span>
        <h2 id="person-label" class="xdoc-editable xdoc-label-label xdoc-select-[Software,Electrical,Mechinical]">{{ basics.label }}</h2>
        {% endif %}
        {% if basics.summary %}
        <span class="between"></span>
        <p id="person-summary" class="xdoc-editable xdoc-textarea xdoc-label-summary">{{ basics.summary }}</p>
        {% endif %}
    </header>
    
    {% if education %}
    <section class="education-list list">
        <h1>Education</h1>
        {% for edu in education %}
        <div class="education-item item-{{ forloop.index }} {% if forloop.last %}item-last{% endif %} item">
            <header>
                {% if edu.area %}<h2 class="education-area">{{ edu.area }}</h2>{% endif %}
                {% if edu.startDate or edu.endDate %}
                <span class="between"></span>
                <span class="dates education-dates">
                    {% if edu.startDate and edu.endDate %}
                        <span class="has-start has-end">
                    {% else %}
                        {% if edu.startDate %}
                            <span class="has-start no-end">
                        {% else %}
                            {% if edu.endDate %}
                                <span class="no-start has-end">
                            {% else %}
                                <span class="">
                            {% endif %}
                        {% endif %}
                    {% endif %}
                        {% if edu.startDate %}<span class="date-start">{{ edu.startDate }}</span>{% endif %}
                        <span class="date-delimiter"></span>
                        {% if edu.endDate %}<span class="date-end">{{ edu.endDate }}</span>{% endif %}
                    </span>
                </span>
                {% endif %}
                {% if edu.studyType %}
                <span class="between"></span>
                <span class="education-studyType">{{ edu.studyType }}</span>
                {% endif %}
                <span class="between"></span>
                <span class="{% if edu.url %}has-url{% else %}no-url{% endif %}">
                    {% if edu.url %}<a href="{{ edu.url }}" target="_blank" rel="external">{{ edu.institution }}</a>
                    {% else %}{{ edu.institution }}{% endif %}
                </span>
            </header>
            <main>
                {% if edu.summary %}<p class="education-summary">{{ edu.summary }}</p>{% endif %}
            </main>
        </div>
        {% endfor %}
    </section>
    {% endif %}
    
    {% if work %}
    <section class="work-list list">
        <h1>Employment</h1>
        {% for job in work %}
        <div class="work-item item-{{ forloop.index }} {% if forloop.last %}item-last{% endif %} item">
            <header>
                {% if job.position %}<h2 class="work-position">{{ job.position }}</h2>{% endif %}
                {% if job.startDate or job.endDate %}
                <span class="between"></span>
                <span class="dates work-dates">
                    {% if job.startDate and job.endDate %}
                        <span class="has-start has-end">
                    {% else %}
                        {% if job.startDate %}
                            <span class="has-start no-end">
                        {% else %}
                            {% if job.endDate %}
                                <span class="no-start has-end">
                            {% else %}
                                <span class="">
                            {% endif %}
                        {% endif %}
                    {% endif %}
                        {% if job.startDate %}<span class="date-start">{{ job.startDate }}</span>{% endif %}
                        <span class="date-delimiter"></span>
                        {% if job.endDate %}<span class="date-end">{{ job.endDate }}</span>{% endif %}
                    </span>
                </span>
                {% endif %}
                {% if job.name %}
                <span class="between"></span>
                <span class="{% if job.url %}has-url{% else %}no-url{% endif %}">
                    {% if job.url %}<a href="{{ job.url }}" target="_blank" rel="external">{{ job.name }}</a>
                    {% else %}{{ job.name }}{% endif %}
                </span>
                {% endif %}
                {% if job.location %}
                <span class="between"></span>
                <span class="work-location">{{ job.location }}</span>
                {% endif %}
            </header>
            <main>
                {% if job.summary %}<p class="work-summary">{{ job.summary }}</p>{% endif %}
                {% if job.highlights %}
                <ul class="work-highlights-list list">
                    {% for highlight in job.highlights %}
                    <li class="work-highlights-item item-{{ forloop.index }} {% if forloop.last %}item-last{% endif %}">
                        {{ highlight }}
                    </li>
                    {% endfor %}
                </ul>
                {% endif %}
            </main>
        </div>
        {% endfor %}
    </section>
    {% endif %}
    
    {% if references %}
    <section class="reference-list list">
        <h1>References</h1>
        {% for ref in references %}
        <div class="reference-item item-{{ forloop.index }} {% if forloop.last %}item-last{% endif %} item">
            <h2 class="reference-name">{{ ref.name }}</h2>
            {% if ref.reference %}<p class="reference-reference">{{ ref.reference }}</p>{% endif %}
        </div>
        {% endfor %}
    </section>
    {% endif %}
</section>

<section id="right" class=" ">
    {% if basics.image %}
    <img class="xdoc-editable xdoc-upload" src="{{ basics.image }}" id="avatar" alt="{{ basics.name }}">
    {% endif %}
    
    <section id="contact" class="list">
        <h1 id="basics-contact" class=" ">Contact</h1>
        
        {% if basics.url %}
        <section id="person-url">
            <h2 id="basics-url" class=" ">URL</h2>
            <img id="img-url" src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iaXNvLTg4NTktMSI/Pg0KPHN2ZyB2ZXJzaW9uPSIxLjEiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgdmlld0JveD0iMCAwIDMwMCAzMDAiPg0KCQk8Zz4NCgkJCTxwYXRoIGQ9Ik0xNDkuOTk2LDBDNjcuMTU3LDAsMC4wMDEsNjcuMTYxLDAuMDAxLDE0OS45OTdTNjcuMTU3LDMwMCwxNDkuOTk2LDMwMHMxNTAuMDAzLTY3LjE2MywxNTAuMDAzLTE1MC4wMDMNCgkJCQlTMjMyLjgzNSwwLDE0OS45OTYsMHogTTIyNS4zNjMsMTIzLjMwMmwtMzYuNjg2LDM2LjY4NmMtMy45NzksMy45NzktOS4yNjksNi4xNy0xNC44OTUsNi4xN2MtNS42MjUsMC0xMC45MTYtMi4xOTItMTQuODk1LTYuMTY4DQoJCQkJbC0xLjQzNy0xLjQzN2wtMy45MDYsMy45MDZsMS40MzQsMS40MzRjOC4yMTQsOC4yMTQsOC4yMTQsMjEuNTc5LDAsMjkuNzkzbC0zNi42ODEsMzYuNjg2Yy0zLjk3OSwzLjk3OS05LjI2OSw2LjE3LTE0Ljg5OCw2LjE3DQoJCQkJYy01LjYyOCwwLTEwLjkxOS0yLjE5Mi0xNC45LTYuMTczTDc0LjYzNCwyMTYuNWMtOC4yMTQtOC4yMDktOC4yMTQtMjEuNTczLTAuMDAzLTI5Ljc5bDM2LjY4OS0zNi42ODQNCgkJCQljMy45NzktMy45NzksOS4yNjktNi4xNywxNC44OTgtNi4xN3MxMC45MTYsMi4xOTIsMTQuODk4LDYuMTdsMS40MzIsMS40MzJsMy45MDYtMy45MDZsLTEuNDMyLTEuNDMyDQoJCQkJYy04LjIxNC04LjIxMS04LjIxNC0yMS41NzYtMC4wMDUtMjkuNzlsMzYuNjg5LTM2LjY4NmMzLjk4MS0zLjk4MSw5LjI3Mi02LjE3MywxNC44OTgtNi4xNzNzMTAuOTE2LDIuMTkyLDE0Ljg5OCw2LjE3DQoJCQkJbDEzLjg2OCwxMy44NzNDMjMzLjU3NywxMDEuNzIzLDIzMy41NzcsMTE1LjA5LDIyNS4zNjMsMTIzLjMwMnoiLz4NCiAgICAgICAgICAgIDxwYXRoIGQ9Ik0xNDIuNTM5LDE3My40NTlsLTcuMDkzLDcuMDkzbC0xMS4wMDItMTAuOTk5bDcuMDkzLTcuMDkzbC0xLjQzMi0xLjQzMmMtMS4wNC0xLjAzNy0yLjQyMi0xLjYxMS0zLjg5LTEuNjExDQoJCQkJYy0xLjQ3MSwwLTIuODUzLDAuNTczLTMuODkzLDEuNjExbC0zNi42ODYsMzYuNjgxYy0yLjE0NSwyLjE0Ny0yLjE0NSw1LjYzOCwwLDcuNzgzbDEzLjg3LDEzLjg3Mw0KCQkJCWMyLjA4MywyLjA4Myw1LjcwOCwyLjA4LDcuNzg2LDAuMDAzbDM2LjY4MS0zNi42ODZjMi4xNDgtMi4xNDcsMi4xNDgtNS42NDEsMC03Ljc4OUwxNDIuNTM5LDE3My40NTl6Ii8+DQogICAgICAgICAgICA8cGF0aCBkPSJNMjAwLjQ5Myw5MC42NDNjLTEuMDQtMS4wNC0yLjQyNS0xLjYxMy0zLjg5Ni0xLjYxM2MtMS40NzEsMC0yLjg1NiwwLjU3My0zLjg5NiwxLjYxNmwtMzYuNjg2LDM2LjY4NA0KCQkJCWMtMi4xNDIsMi4xNDctMi4xNDIsNS42MzgsMC4wMDMsNy43ODZsMS40MzQsMS40MzJsMTAuODgtMTAuODgzbDExLjAwMiwxMS4wMDJsLTEwLjg4LDEwLjg4M2wxLjQzNCwxLjQzNA0KCQkJCWMyLjA4MywyLjA3Nyw1LjcwMywyLjA4LDcuNzg2LTAuMDAzbDM2LjY4NC0zNi42ODFjMi4xNDUtMi4xNDcsMi4xNDUtNS42MzgsMC03Ljc4NkwyMDAuNDkzLDkwLjY0M3oiLz4NCgkJPC9nPg0KPC9zdmc+DQo=" alt="URL" class="icon">
            <p class="xdoc-editable">{{ basics.url }}</p>
        </section>
        {% endif %}
        
        {% if basics.email %}
        <section id="person-email">
            <h2 id="basics-email" class=" ">E-mail</h2>
            <img id="img-email" src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iaXNvLTg4NTktMSI/Pgo8c3ZnIHZpZXdCb3g9IjAgMCA1MTIgNTEyIiB2ZXJzaW9uPSIxLjEiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CiAgICA8Zz4KICAgICAgICA8cGF0aCBkPSJNMjU2LDBDMTE0LjYxNSwwLDAsMTE0LjYxNSwwLDI1NnMxMTQuNjE1LDI1NiwyNTYsMjU2czI1Ni0xMTQuNjE1LDI1Ni0yNTZTMzk3LjM4NSwwLDI1NiwweiBNNDEyLDM1My41ICAgYzAsMjAuMTkzLTE2LjM3LDM2LjU2Mi0zNi41NjIsMzYuNTYySDEzNi41NjJjLTIwLjE5MywwLTM2LjU2Mi0xNi4zNy0zNi41NjItMzYuNTYydi0xOTVjMC0yMC4xOTMsMTYuMzctMzYuNTYyLDM2LjU2Mi0zNi41NjIgICBoMjM4Ljg3NWMyMC4xOTMsMCwzNi41NjIsMTYuMzcsMzYuNTYyLDM2LjU2MlYzNTMuNXoiLz4KICAgICAgICA8cGF0aCBkPSJNMzM0LjQ2MywxNjYuNzAzTDI1NiwyMTIuMDA0bC03OC40NjMtNDUuMzAxYy04Ljc0NC01LjA0OC0xOS45MjQtMi4wNTItMjQuOTczLDYuNjkxICAgYy01LjA0OCw4Ljc0NC0yLjA1MiwxOS45MjQsNi42OTEsMjQuOTczbDg3LjYwNCw1MC41NzhsMC4wMDEtMC4wMDJjMi43NzcsMS42LDUuOTM2LDIuNDQzLDkuMTM5LDIuNDQ4ICAgYzMuMjA0LTAuMDA0LDYuMzYzLTAuODQ4LDkuMTM5LTIuNDQ4bDAuMDAxLDAuMDAybDg3LjYwNC01MC41NzhjOC43NDQtNS4wNDgsMTEuNzQtMTYuMjI5LDYuNjkxLTI0Ljk3MyAgIEMzNTQuMzg4LDE2NC42NTEsMzQzLjIwNywxNjEuNjU1LDMzNC40NjMsMTY2LjcwM3oiLz4KICAgIDwvZz4KPC9zdmc+Cg==" alt="E-mail" class="icon">
            <p class="xdoc-editable xdoc-label-label xdoc-checkbox-[basit@gmail.com,basit.munir19@gmail.com,basit@hc.com]">{{ basics.email }}</p>
        </section>
        {% endif %}
        
        {% if basics.phone %}
        <section id="person-phone">
            <!--<h2 id="basics-phone" class=" ">Phone</h2>-->
            <!--<span id="img-phone" class=" ">Phone</span>-->
            <img id="img-phone" src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0iY3VycmVudENvbG9yIj48cGF0aCBkPSJNNi42MiAxMC43OWExNS4wNTMgMTUuMDUzIDAgMDA2LjU5IDYuNTlsMi4yLTIuMmExIDEgMCAwMTEuMTEtLjIxYzEuMi40OCAyLjUzLjczIDMuODguNzNhMSAxIDAgMDExIDF2My41YTEgMSAwIDAxLTEgMUMxMC4wNyAyMiAyIDEzLjkzIDIgNGExIDEgMCAwMTEtMWgzLjVhMSAxIDAgMDExIDFjMCAxLjM1LjI1IDIuNjguNzMgMy44OGExIDEgMCAwMS0uMjEgMS4xMWwtMi4yIDIuMnoiLz48L3N2Zz4=" alt="E-mail" class="icon">
            <p class="xdoc-editable xdoc-label-phone xdoc-radio-[03355862952,00000000,111111111]">{{ basics.phone }}</p>
        </section>
        {% endif %}
        
        {% if basics.location %}
        <section id="person-location">
            <h2 id="basics-location" class=" ">Location</h2>
            <span class="between"></span>
            <img id="img-location" src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0idXRmLTgiPz4KPHN2ZyB2aWV3Qm94PSIwIDAgMTYgMTYiIHZlcnNpb249IjEuMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICAgIDxwYXRoIGZpbGw9IiMwMDAiIGQ9Ik04IDBjLTQuNCAwLTggMy42LTggOHMzLjYgOCA4IDggOC0zLjYgOC04LTMuNi04LTgtOHpNNyAxNHYtNWgtNWwxMC01LTUgMTB6Ii8+Cjwvc3ZnPgo=" alt="Location" class="icon">
            <span class="between"></span>
            <main class="person-location-parts">
                {% if basics.location.city %}<span class="person-location-city">{{ basics.location.city }}</span><span class="between"></span>{% endif %}
                {% if basics.location.countryCode %}<span class="person-location-countryCode">{{ basics.location.countryCode }}</span>{% endif %}
            </main>
        </section>
        {% endif %}
        
        {% if basics.profiles %}
        <section class="profile-list list">
            <h2 id="basics-profiles" class=" ">Profiles</h2>
            {% for profile in basics.profiles %}
            <div class="profile-item item-{{ forloop.index }} {% if forloop.last %}item-last{% endif %} item">
                <a href="{{ profile.url }}" class="profile-url" target="_blank" rel="external">
                    <span class="profile-network profile-network-{{ profile.network | downcase }}">{{ profile.network }}</span>
                    {% if profile.network == "github" %}
                    <img id="img-github" src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0idXRmLTgiPz4KPHN2ZyB2aWV3Qm94PSIwIDAgNjQgNjQiIHZlcnNpb249IjEuMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICAgIDxwYXRoIHN0cm9rZS13aWR0aD0iMCIgZmlsbD0iIzAwMCIgZD0iTTMyIDAgQzE0IDAgMCAxNCAwIDMyIDAgNTMgMTkgNjIgMjIgNjIgMjQgNjIgMjQgNjEgMjQgNjAgTDI0IDU1IEMxNyA1NyAxNCA1MyAxMyA1MCAxMyA1MCAxMyA0OSAxMSA0NyAxMCA0NiA2IDQ0IDEwIDQ0IDEzIDQ0IDE1IDQ4IDE1IDQ4IDE4IDUyIDIyIDUxIDI0IDUwIDI0IDQ4IDI2IDQ2IDI2IDQ2IDE4IDQ1IDEyIDQyIDEyIDMxIDEyIDI3IDEzIDI0IDE1IDIyIDE1IDIyIDEzIDE4IDE1IDEzIDE1IDEzIDIwIDEzIDI0IDE3IDI3IDE1IDM3IDE1IDQwIDE3IDQ0IDEzIDQ5IDEzIDQ5IDEzIDUxIDIwIDQ5IDIyIDQ5IDIyIDUxIDI0IDUyIDI3IDUyIDMxIDUyIDQyIDQ1IDQ1IDM4IDQ2IDM5IDQ3IDQwIDQ5IDQwIDUyIEw0MCA2MCBDNDAgNjEgNDAgNjIgNDIgNjIgNDUgNjIgNjQgNTMgNjQgMzIgNjQgMTQgNTAgMCAzMiAwIFoiLz4KPC9zdmc+Cg==" alt="github" class="icon">
                    {% else %}
                    <span id="img-{{ profile.network | downcase }}" class="">{{ profile.network }}</span>
                    {% endif %}
                    <span class="profile-username">{{ profile.username }}</span>
                </a>
            </div>
            {% endfor %}
        </section>
        {% endif %}
    </section>

    {% if awards %}
    <section class="award-list list">
        <h1>Awards</h1>
        {% for award in awards %}
        <div class="award-item item-{{ forloop.index }} {% if forloop.last %}item-last{% endif %} item">
            <header>
                <h2 class="award-title">{{ award.title }}</h2>
                {% if award.date %}
                <span class="between"></span>
                <span class="award-date">{{ award.date }}</span>
                {% endif %}
                {% if award.awarder %}
                <span class="between"></span>
                <span class="award-awarder">{{ award.awarder }}</span>
                {% endif %}
            </header>
            <main>
                {% if award.summary %}<p class="award-summary">{{ award.summary }}</p>{% endif %}
            </main>
        </div>
        {% endfor %}
    </section>
    {% endif %}
    
    {% if projects %}
    <section class="project-list list">
        <h1>Projects</h1>
        {% for project in projects %}
        <div class="project-no-type project-item item-{{ forloop.index }} {% if forloop.last %}item-last{% endif %} item">
            <header>
                <h2 class="project-name">{{ project.name }}</h2>
                {% if project.startDate or project.endDate %}
                <span class="between"></span>
                <span class="dates project-dates">
                    {% if project.startDate and project.endDate %}
                        <span class="has-start has-end">
                    {% else %}
                        {% if project.startDate %}
                            <span class="has-start no-end">
                        {% else %}
                            {% if project.endDate %}
                                <span class="no-start has-end">
                            {% else %}
                                <span class="">
                            {% endif %}
                        {% endif %}
                    {% endif %}
                        {% if project.startDate %}<span class="date-start">{{ project.startDate }}</span>{% endif %}
                        <span class="date-delimiter"></span>
                        {% if project.endDate %}<span class="date-end">{{ project.endDate }}</span>{% endif %}
                    </span>
                </span>
                {% endif %}
            </header>
            <main>
                {% if project.description %}<p class="project-description">{{ project.description }}</p>{% endif %}
                {% if project.highlights %}
                <ul class="project-highlights-list list">
                    {% for highlight in project.highlights %}
                    <li class="project-highlights-item item-{{ forloop.index }} {% if forloop.last %}item-last{% endif %}">
                        {{ highlight }}
                    </li>
                    {% endfor %}
                </ul>
                {% endif %}
            </main>
            <footer>
                {% if project.url %}<a href="{{ project.url }}" class="project-url-a" target="_blank" rel="external">{{ project.url }}</a>{% endif %}
            </footer>
        </div>
        {% endfor %}
    </section>
    {% endif %}
    
    {% if skills %}
    <section class="skill-list list">
        <h1>Skills</h1>
        {% for skill in skills %}
        <div class="skill-no-level skill-item item-{{ forloop.index }} {% if forloop.last %}item-last{% endif %} item">
            <header>
                <h2 class="skill-name">{{ skill.name }}</h2>
                {% if skill.level %}
                <span class="between"></span>
                <span class="skill-level">{{ skill.level }}</span>
                {% endif %}
            </header>
            {% if skill.keywords %}
            <ul class="skill-keyword-list list">
                {% for keyword in skill.keywords %}
                <li class="skill-keyword-item item-{{ forloop.index }} {% if forloop.last %}item-last{% endif %}">
                    {{ keyword }}
                </li>
                {% endfor %}
            </ul>
            {% endif %}
        </div>
        {% endfor %}
    </section>
    {% endif %}
    
    {% if interests %}
    <section class="interest-list list">
        <h1>Interests</h1>
        {% for interest in interests %}
        <div class="interest-item item-{{ forloop.index }} {% if forloop.last %}item-last{% endif %} item">
            <header>
                <h2 class="interest-name">{{ interest.name }}</h2>
            </header>
            {% if interest.keywords %}
            <ul class="interest-keyword-list list">
                {% for keyword in interest.keywords %}
                <li class="interest-keyword-item item-{{ forloop.index }} {% if forloop.last %}item-last{% endif %}">
                    {{ keyword }}
                </li>
                {% endfor %}
            </ul>
            {% endif %}
        </div>
        {% endfor %}
    </section>
    {% endif %}
</section>
</article>
</body>
<script>
document.addEventListener("DOMContentLoaded", function() { 
  // Create popup elements
  const popup = document.createElement('div');
  popup.style.position = 'fixed';
  popup.style.top = '50%';
  popup.style.left = '50%';
  popup.style.transform = 'translate(-50%, -50%)';
  popup.style.backgroundColor = 'white';
  popup.style.padding = '20px';
  popup.style.border = '1px solid #ccc';
  popup.style.borderRadius = '5px';
  popup.style.boxShadow = '0 2px 10px rgba(0,0,0,0.2)';
  popup.style.zIndex = '1000';
  popup.style.display = 'none';
  popup.style.minWidth = '300px';
  popup.style.maxWidth = '80vw';

  // Create label element
  const popupLabel = document.createElement('div');
  popupLabel.style.marginBottom = '10px';
  popupLabel.style.fontWeight = 'bold';
  popupLabel.style.fontSize = '16px';
  popupLabel.textContent = 'EDIT VALUE'; // Default label text

  // Create input element
  const input = document.createElement('input');
  input.type = 'text';
  input.style.width = '100%';
  input.style.marginBottom = '10px';
  input.style.padding = '5px';
  input.style.outline = 'none';
  input.style.border = '1px solid #ccc';
  input.style.borderRadius = '3px';
  input.style.display = 'none'; // Initially hidden

  // Create textarea element
  const textarea = document.createElement('textarea');
  textarea.style.width = '100%';
  textarea.style.marginBottom = '10px';
  textarea.style.padding = '5px';
  textarea.style.outline = 'none';
  textarea.style.border = '1px solid #ccc';
  textarea.style.borderRadius = '3px';
  textarea.style.display = 'none'; // Initially hidden
  textarea.style.minHeight = '100px';
  textarea.style.resize = 'vertical';

  // Create select element
  const select = document.createElement('select');
  select.style.width = '100%';
  select.style.marginBottom = '10px';
  select.style.padding = '5px';
  select.style.outline = 'none';
  select.style.border = '1px solid #ccc';
  select.style.borderRadius = '3px';
  select.style.display = 'none'; // Initially hidden

  // Create radio container
  const radioContainer = document.createElement('div');
  radioContainer.style.display = 'flex';
  radioContainer.style.flexDirection = 'column';
  radioContainer.style.gap = '8px';
  radioContainer.style.marginBottom = '10px';
  radioContainer.style.display = 'none';

  // Create checkbox container
  const checkboxContainer = document.createElement('div');
  checkboxContainer.style.display = 'flex';
  checkboxContainer.style.flexDirection = 'column';
  checkboxContainer.style.gap = '8px';
  checkboxContainer.style.marginBottom = '10px';
  checkboxContainer.style.display = 'none';

  // Create upload container
  const uploadContainer = document.createElement('div');
  uploadContainer.style.display = 'none';
  uploadContainer.style.flexDirection = 'column';
  uploadContainer.style.gap = '10px';
  uploadContainer.style.marginBottom = '10px';

  // Create drop zone
  const dropZone = document.createElement('div');
  dropZone.style.border = '2px dashed #ccc';
  dropZone.style.borderRadius = '5px';
  dropZone.style.padding = '20px';
  dropZone.style.textAlign = 'center';
  dropZone.style.cursor = 'pointer';
  dropZone.style.marginBottom = '10px';
  dropZone.innerHTML = `
    <p>Drag & drop image here</p>
    <p>or</p>
    <button id="file-upload-btn" style="padding: 5px 15px; background: #f0f0f0; border: 1px solid #ccc; border-radius: 3px;">
      Choose File
    </button>
    <p>or paste (Ctrl+V)</p>
  `;

  // Create file input (hidden)
  const fileInput = document.createElement('input');
  fileInput.type = 'file';
  fileInput.accept = 'image/*';
  fileInput.style.display = 'none';

  // Create image preview
  const imagePreview = document.createElement('img');
  imagePreview.style.maxWidth = '100%';
  imagePreview.style.maxHeight = '200px';
  imagePreview.style.display = 'none';
  imagePreview.style.margin = '0 auto';

  uploadContainer.appendChild(dropZone);
  uploadContainer.appendChild(fileInput);
  uploadContainer.appendChild(imagePreview);

  const buttonContainer = document.createElement('div');
  buttonContainer.style.display = 'flex';
  buttonContainer.style.justifyContent = 'flex-end';
  buttonContainer.style.gap = '10px';

  const okButton = document.createElement('button');
  okButton.textContent = 'OK';
  okButton.style.padding = '5px 15px';
  okButton.style.outline = 'none';
  okButton.style.borderRadius = '3px';
  okButton.style.border = '1px solid #ccc';
  okButton.style.backgroundColor = '#f0f0f0';

  const cancelButton = document.createElement('button');
  cancelButton.textContent = 'Cancel';
  cancelButton.style.padding = '5px 15px';
  cancelButton.style.outline = 'none';
  cancelButton.style.borderRadius = '3px';
  cancelButton.style.border = '1px solid #ccc';
  cancelButton.style.backgroundColor = '#f0f0f0';

  // Focus styles
  const setFocusStyle = (element) => {
    element.addEventListener('focus', function() {
      // For radio/checkbox, we'll style their parent container
      if (element.type === 'radio' || element.type === 'checkbox') {
        const parent = element.parentElement;
        if (parent) {
          parent.style.border = '2px solid blue';
          parent.style.borderRadius = '3px';
          parent.style.padding = '2px';
          parent.style.margin = '-2px';
        }
      } else {
        element.style.border = '2px solid blue';
      }
    });
    
    element.addEventListener('blur', function() {
      // For radio/checkbox, remove style from parent
      if (element.type === 'radio' || element.type === 'checkbox') {
        const parent = element.parentElement;
        if (parent) {
          parent.style.border = 'none';
          parent.style.padding = '0';
          parent.style.margin = '0';
        }
      } else {
        element.style.border = '1px solid #ccc';
      }
    });
  };

  setFocusStyle(input);
  setFocusStyle(textarea);
  setFocusStyle(select);
  setFocusStyle(okButton);
  setFocusStyle(cancelButton);

  buttonContainer.appendChild(okButton);
  buttonContainer.appendChild(cancelButton);

  // Append label first, then all input types, then buttons
  popup.appendChild(popupLabel);
  popup.appendChild(input);
  popup.appendChild(textarea);
  popup.appendChild(select);
  popup.appendChild(radioContainer);
  popup.appendChild(checkboxContainer);
  popup.appendChild(uploadContainer);
  popup.appendChild(buttonContainer);
  document.body.appendChild(popup);

  // Add style for radio/checkbox labels
  const style = document.createElement('style');
  style.textContent = `
    input[type="radio"] + label,
    input[type="checkbox"] + label {
      cursor: pointer;
      user-select: none;
    }
  `;
  document.head.appendChild(style);

  // Variables to track current element and callback
  let currentElement = null;
  let resolveCallback = null;
  let currentBase64 = null;

  // Function to set popup label based on class names
  function setPopupLabel(element) {
    // Find the first class that starts with xdoc-label-
    const labelClass = Array.from(element.classList).find(className => 
      className.startsWith('xdoc-label-')
    );
    
    if (labelClass) {
      // Split by hyphens and get the third part
      const parts = labelClass.split('-');
      if (parts.length >= 3) {
        // Use the third part as uppercase label
        popupLabel.textContent = parts[2].toUpperCase();
        return;
      }
    }
    // Default label if no matching class found
    popupLabel.textContent = element.classList.contains('xdoc-upload') ? 'UPLOAD IMAGE' : 'EDIT VALUE';
  }

  // Function to get select options from class
  function getSelectOptions(element) {
    const selectClass = Array.from(element.classList).find(className => 
      className.startsWith('xdoc-select-')
    );
    
    if (selectClass) {
      // Extract the options between the square brackets
      const optionsMatch = selectClass.match(/\[(.*?)\]/);
      if (optionsMatch && optionsMatch[1]) {
        return {
          type: 'select',
          options: optionsMatch[1].split(',')
        };
      }
    }
    return null;
  }

  // Function to get radio options from class
  function getRadioOptions(element) {
    const radioClass = Array.from(element.classList).find(className => 
      className.startsWith('xdoc-radio-')
    );
    
    if (radioClass) {
      // Extract the options between the square brackets
      const optionsMatch = radioClass.match(/\[(.*?)\]/);
      if (optionsMatch && optionsMatch[1]) {
        return {
          type: 'radio',
          options: optionsMatch[1].split(',')
        };
      }
    }
    return null;
  }

  // Function to get checkbox options from class
  function getCheckboxOptions(element) {
    const checkboxClass = Array.from(element.classList).find(className => 
      className.startsWith('xdoc-checkbox-')
    );
    
    if (checkboxClass) {
      // Extract the options between the square brackets
      const optionsMatch = checkboxClass.match(/\[(.*?)\]/);
      if (optionsMatch && optionsMatch[1]) {
        return {
          type: 'checkbox',
          options: optionsMatch[1].split(',')
        };
      }
    }
    return null;
  }

  // Function to handle file and convert to base64
  function handleFile(file) {
    if (!file.type.match('image.*')) {
      alert('Please select an image file');
      return;
    }

    const reader = new FileReader();
    reader.onload = function(e) {
      currentBase64 = e.target.result;
      imagePreview.src = currentBase64;
      imagePreview.style.display = 'block';
      dropZone.style.borderColor = '#4CAF50'; // Green border on success
      setTimeout(() => dropZone.style.borderColor = '#ccc', 1000);
    };
    reader.readAsDataURL(file);
  }

  // Set up file input click
  const fileUploadBtn = dropZone.querySelector('#file-upload-btn');
  fileUploadBtn.addEventListener('click', () => fileInput.click());
  
  // Handle file selection
  fileInput.addEventListener('change', function(e) {
    if (e.target.files.length) {
      handleFile(e.target.files[0]);
    }
  });

  // Handle drag and drop
  dropZone.addEventListener('dragover', function(e) {
    if (uploadContainer.style.display !== 'flex') return;
    e.preventDefault();
    e.stopPropagation();
    dropZone.style.borderColor = '#2196F3'; // Blue border on dragover
    dropZone.style.backgroundColor = '#f5f5f5';
  });

  dropZone.addEventListener('dragleave', function(e) {
    if (uploadContainer.style.display !== 'flex') return;
    e.preventDefault();
    e.stopPropagation();
    dropZone.style.borderColor = '#ccc';
    dropZone.style.backgroundColor = '';
  });

  dropZone.addEventListener('drop', function(e) {
    if (uploadContainer.style.display !== 'flex') return;
    e.preventDefault();
    e.stopPropagation();
    dropZone.style.borderColor = '#ccc';
    dropZone.style.backgroundColor = '';

    if (e.dataTransfer.files.length) {
      handleFile(e.dataTransfer.files[0]);
    }
  });

  // Handle paste event
  document.addEventListener('paste', function(e) {
    if (uploadContainer.style.display !== 'flex') return;
    
    const items = e.clipboardData.items;
    for (let i = 0; i < items.length; i++) {
      if (items[i].type.indexOf('image') !== -1) {
        const blob = items[i].getAsFile();
        handleFile(blob);
        break;
      }
    }
  });

  // Function to show popup with appropriate input type
  function showPopup(text, element) {
    // Hide all inputs first
    input.style.display = 'none';
    textarea.style.display = 'none';
    select.style.display = 'none';
    radioContainer.style.display = 'none';
    checkboxContainer.style.display = 'none';
    uploadContainer.style.display = 'none';

    // Set popup label based on element's classes
    setPopupLabel(element);

    // Check if this is an upload element
    const isUpload = element.classList.contains('xdoc-upload');
    
    if (isUpload) {
      // Set up upload interface
      uploadContainer.style.display = 'flex';
      currentBase64 = element.src || '';
      
      // Show current image if it exists
      if (element.src) {
        imagePreview.src = element.src;
        imagePreview.style.display = 'block';
      } else {
        imagePreview.style.display = 'none';
      }
      
      // Focus on the file input button
      setTimeout(() => fileUploadBtn.focus(), 0);
    }
    else {
      // Check for other input types based on classes
      const selectOptions = getSelectOptions(element);
      const radioOptions = getRadioOptions(element);
      const checkboxOptions = getCheckboxOptions(element);
      const isTextarea = element.classList.contains('xdoc-textarea');

      if (checkboxOptions) {
        // Clear any existing checkboxes
        checkboxContainer.innerHTML = '';
        
        // Split current text by comma to get selected values
        const selectedValues = text ? text.split(',').map(item => item.trim()) : [];
        
        // Add new checkboxes
        checkboxOptions.options.forEach(option => {
          const checkboxWrapper = document.createElement('div');
          checkboxWrapper.style.display = 'flex';
          checkboxWrapper.style.alignItems = 'center';
          checkboxWrapper.style.gap = '8px';
          
          const checkboxInput = document.createElement('input');
          checkboxInput.type = 'checkbox';
          checkboxInput.name = 'xdoc-checkbox-group';
          checkboxInput.value = option;
          checkboxInput.id = `checkbox-${option}`;
          
          // Check if this option is in the selected values
          if (selectedValues.includes(option)) {
            checkboxInput.checked = true;
          }
          
          const checkboxLabel = document.createElement('label');
          checkboxLabel.htmlFor = `checkbox-${option}`;
          checkboxLabel.textContent = option;
          
          checkboxWrapper.appendChild(checkboxInput);
          checkboxWrapper.appendChild(checkboxLabel);
          checkboxContainer.appendChild(checkboxWrapper);
          
          // Apply focus style to the checkbox
          setFocusStyle(checkboxInput);
        });
        
        checkboxContainer.style.display = 'flex';
        
        // Focus on first checkbox if any
        setTimeout(() => {
          const firstCheckbox = checkboxContainer.querySelector('input[type="checkbox"]');
          if (firstCheckbox) firstCheckbox.focus();
        }, 0);
      }
      else if (radioOptions) {
        // Clear any existing radio buttons
        radioContainer.innerHTML = '';
        
        // Add new radio buttons
        radioOptions.options.forEach(option => {
          const radioWrapper = document.createElement('div');
          radioWrapper.style.display = 'flex';
          radioWrapper.style.alignItems = 'center';
          radioWrapper.style.gap = '8px';
          
          const radioInput = document.createElement('input');
          radioInput.type = 'radio';
          radioInput.name = 'xdoc-radio-group';
          radioInput.value = option;
          radioInput.id = `radio-${option}`;
          
          const radioLabel = document.createElement('label');
          radioLabel.htmlFor = `radio-${option}`;
          radioLabel.textContent = option;
          
          // Check if this option matches the current text
          if (option === text) {
            radioInput.checked = true;
          }
          
          radioWrapper.appendChild(radioInput);
          radioWrapper.appendChild(radioLabel);
          radioContainer.appendChild(radioWrapper);
          
          // Apply focus style to the radio input
          setFocusStyle(radioInput);
        });
        
        radioContainer.style.display = 'flex';
        
        // Focus on first radio button if any
        setTimeout(() => {
          const firstRadio = radioContainer.querySelector('input[type="radio"]');
          if (firstRadio) firstRadio.focus();
        }, 0);
      }
      else if (selectOptions) {
        // Clear any existing options
        select.innerHTML = '';
        
        // Add new options
        selectOptions.options.forEach(option => {
          const optionElement = document.createElement('option');
          optionElement.value = option;
          optionElement.textContent = option;
          select.appendChild(optionElement);
        });
        
        // Set the current value
        select.value = text;
        select.style.display = 'block';
        setTimeout(() => select.focus(), 0);
      } 
      else if (isTextarea) {
        textarea.value = text;
        textarea.style.display = 'block';
        setTimeout(() => {
          textarea.focus();
          textarea.select();
        }, 0);
      } 
      else {
        input.value = text;
        input.style.display = 'block';
        setTimeout(() => {
          input.focus();
          input.select();
        }, 0);
      }
    }

    popup.style.display = 'block';

    return new Promise((resolve) => {
      resolveCallback = resolve;
    });
  }

  // Button event handlers
  okButton.addEventListener('click', function() {
    popup.style.display = 'none';
    if (resolveCallback) {
      let value;
      if (uploadContainer.style.display === 'flex') {
        value = currentBase64;
      } else if (checkboxContainer.style.display === 'flex') {
        const selectedCheckboxes = Array.from(
          document.querySelectorAll('input[name="xdoc-checkbox-group"]:checked')
        ).map(checkbox => checkbox.value);
        value = selectedCheckboxes.join(', ');
      } else if (radioContainer.style.display === 'flex') {
        const selectedRadio = document.querySelector('input[name="xdoc-radio-group"]:checked');
        value = selectedRadio ? selectedRadio.value : null;
      } else if (select.style.display === 'block') {
        value = select.value;
      } else if (textarea.style.display === 'block') {
        value = textarea.value;
      } else {
        value = input.value;
      }
      resolveCallback(value);
      resolveCallback = null;
    }
  });

  cancelButton.addEventListener('click', function() {
    popup.style.display = 'none';
    if (resolveCallback) {
      resolveCallback(null);
      resolveCallback = null;
    }
  });

  // Close popup when clicking outside
  popup.addEventListener('click', function(e) {
    e.stopPropagation();
  });

  document.addEventListener('click', function() {
    if (popup.style.display === 'block') {
      popup.style.display = 'none';
      if (resolveCallback) {
        resolveCallback(null);
        resolveCallback = null;
      }
    }
  });

  // Handle Enter/Escape keys in popup
  const handlePopupKeydown = (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      popup.style.display = 'none';
      if (resolveCallback) {
        let value;
        if (uploadContainer.style.display === 'flex') {
          value = currentBase64;
        } else if (checkboxContainer.style.display === 'flex') {
          const selectedCheckboxes = Array.from(
            document.querySelectorAll('input[name="xdoc-checkbox-group"]:checked')
          ).map(checkbox => checkbox.value);
          value = selectedCheckboxes.join(', ');
        } else if (radioContainer.style.display === 'flex') {
          const selectedRadio = document.querySelector('input[name="xdoc-radio-group"]:checked');
          value = selectedRadio ? selectedRadio.value : null;
        } else if (select.style.display === 'block') {
          value = select.value;
        } else if (textarea.style.display === 'block') {
          value = textarea.value;
        } else {
          value = input.value;
        }
        resolveCallback(value);
        resolveCallback = null;
      }
    } else if (e.key === 'Escape') {
      popup.style.display = 'none';
      if (resolveCallback) {
        resolveCallback(null);
        resolveCallback = null;
      }
    }
  };

  input.addEventListener('keydown', handlePopupKeydown);
  textarea.addEventListener('keydown', handlePopupKeydown);
  select.addEventListener('keydown', handlePopupKeydown);

  // Select all elements with xdoc-editable class
  document.querySelectorAll(".xdoc-editable").forEach(function(element) {
    element.setAttribute('tabindex', '0'); // Make focusable by tab

    // Double click event
    element.addEventListener("dblclick", async function() {
      currentElement = this;
      const currentValue = this.classList.contains('xdoc-upload') ? this.src : this.innerText;
      const newValue = await showPopup(currentValue, this);
      if (newValue !== null) {
        if (this.classList.contains('xdoc-upload')) {
          this.src = newValue;
        } else {
          this.innerText = newValue;
        }
      }
    });

    // Enter key event
    element.addEventListener('keydown', async function(e) {
      if (e.key === 'Enter') {
        e.preventDefault(); // Prevent default Enter behaviour
        currentElement = this;
        const currentValue = this.classList.contains('xdoc-upload') ? this.src : this.innerText;
        const newValue = await showPopup(currentValue, this);
        if (newValue !== null) {
          if (this.classList.contains('xdoc-upload')) {
            this.src = newValue;
          } else {
            this.innerText = newValue;
          }
        }
      }
    });
  });
});
</script>
</html>''';
}
