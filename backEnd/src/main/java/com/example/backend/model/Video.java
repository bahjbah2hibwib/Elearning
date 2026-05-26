package com.example.backend.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Data
@Table(name = "videos", schema = "elearningmanagerment")
@Entity
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Video {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "video_id", nullable = false)
    private Integer videoId;

    @Column(name = "lesson_id", nullable = false)
    private Integer lessonId;

    @Column(name = "video_type", nullable = false, length = 20)
    private String videoType;

    @Column(name = "video_url", nullable = false, columnDefinition = "TEXT")
    private String videoUrl;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "lesson_id", nullable = false)
    private Lesson lesson;

    @PrePersist
    protected void onCreate(){
        createdAt = LocalDateTime.now();
    }
}
