CREATE SCHEMA IF NOT EXISTS elearningmanagerment;

CREATE TABLE IF NOT EXISTS elearningmanagerment.users(
                                           user_id SERIAL PRIMARY KEY,
                                           full_name VARCHAR(100) NOT NULL,
                                           email VARCHAR(255) NOT NULL UNIQUE,
                                           password VARCHAR(255) NOT NULL,
                                           avatar TEXT,
                                           phone VARCHAR(15) UNIQUE,
                                           date_of_birth DATE,
                                           role VARCHAR(20) NOT NULL,
                                           status BOOLEAN NOT NULL DEFAULT TRUE,
                                           created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                           updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                           CONSTRAINT chk_date_of_birth
                                               CHECK (date_of_birth <= CURRENT_DATE - INTERVAL '16 years'),
    CONSTRAINT chk_user_role CHECK ( role IN ( 'ROLE_STUDENT', 'ROLE_INSTRUCTOR','ROLE_ADMIN') )
);

CREATE TABLE IF NOT EXISTS elearningmanagerment.courses(
                                             course_id SERIAL PRIMARY KEY,
                                             title VARCHAR(255) NOT NULL,
                                             description TEXT NOT NULL,
                                             thumbnail TEXT,
                                             status VARCHAR(20) NOT NULL,
                                             created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                             updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                             instructor_id INT NOT NULL,
                                             CONSTRAINT chk_course_status
                                                 CHECK (
                                                     status IN ( 'PENDING', 'APPROVED', 'HIDDEN')),
                                             CONSTRAINT fk_course_instructor
                                                 FOREIGN KEY (instructor_id)
                                                     REFERENCES elearningmanagerment.users(user_id)
);

CREATE TABLE IF NOT EXISTS elearningmanagerment.enrollments(
                                                 enrollment_id SERIAL PRIMARY KEY,
                                                 enroll_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                                 status BOOLEAN NOT NULL DEFAULT TRUE,
                                                 student_id INT NOT NULL,
                                                 course_id INT NOT NULL,
                                                 CONSTRAINT fk_enrollment_student
                                                     FOREIGN KEY (student_id)
                                                         REFERENCES elearningmanagerment.users(user_id),
                                                 CONSTRAINT fk_enrollment_course
                                                     FOREIGN KEY (course_id)
                                                         REFERENCES elearningmanagerment.courses(course_id),
                                                 CONSTRAINT uq_student_course
                                                     UNIQUE(student_id, course_id)
);

CREATE TABLE IF NOT EXISTS elearningmanagerment.lessons(
                                             lesson_id SERIAL PRIMARY KEY,
                                             course_id INT NOT NULL,
                                             title VARCHAR(255) NOT NULL,
                                             order_index INT NOT NULL,
                                             created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                             updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                             CONSTRAINT fk_lesson_course
                                                 FOREIGN KEY (course_id)
                                                     REFERENCES elearningmanagerment.courses(course_id),
                                             CONSTRAINT uq_course_order
                                                 UNIQUE(course_id, order_index)
);

CREATE TABLE IF NOT EXISTS elearningmanagerment.videos(
                                            video_id SERIAL PRIMARY KEY,
                                            lesson_id INT NOT NULL,
                                            video_type VARCHAR(20) NOT NULL,
                                            video_url TEXT NOT NULL,
                                            created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                            CONSTRAINT chk_video_type CHECK ( video_type IN ( 'UPLOAD', 'YOUTUBE') ),
                                            CONSTRAINT fk_video_lesson
                                                FOREIGN KEY (lesson_id)
                                                    REFERENCES elearningmanagerment.lessons(lesson_id)
);

CREATE TABLE IF NOT EXISTS elearningmanagerment.reading_materials(
                                                       material_id SERIAL PRIMARY KEY,
                                                       lesson_id INT NOT NULL,
                                                       title VARCHAR(255) NOT NULL,
                                                       document_url TEXT NOT NULL,
                                                       created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                                       updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                                       CONSTRAINT fk_material_lesson
                                                           FOREIGN KEY (lesson_id)
                                                               REFERENCES elearningmanagerment.lessons(lesson_id)
);

CREATE TABLE IF NOT EXISTS elearningmanagerment.lesson_progress(
                                                     progress_id SERIAL PRIMARY KEY,
                                                     user_id INT NOT NULL,
                                                     lesson_id INT NOT NULL,
                                                     is_completed BOOLEAN NOT NULL DEFAULT FALSE,
                                                     completed_at TIMESTAMP,
                                                     CONSTRAINT fk_progress_user
                                                         FOREIGN KEY (user_id)
                                                             REFERENCES elearningmanagerment.users(user_id),
                                                     CONSTRAINT fk_progress_lesson
                                                         FOREIGN KEY (lesson_id)
                                                             REFERENCES elearningmanagerment.lessons(lesson_id),
                                                     CONSTRAINT uq_user_lesson
                                                         UNIQUE(user_id, lesson_id)
);


