package com.railway;

import com.formdev.flatlaf.FlatLightLaf;
import javax.swing.*;
import java.awt.*;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class MainApp extends JFrame {
    private JTextArea resultArea;
    private JComboBox<String> querySelector;
    
    public MainApp() {
        setTitle("Railway Management System");
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setSize(800, 600);
        
        // Interface components
        JPanel mainPanel = new JPanel(new BorderLayout(10, 10));
        mainPanel.setBorder(BorderFactory.createEmptyBorder(10, 10, 10, 10));
        
        // Query selector
        String[] queries = {
            "Liste des trajets",
            "Liste des passagers",
            "Personnel par tronçon",
            "Statistiques réservations"
        };
        querySelector = new JComboBox<>(queries);
        
        // Results area
        resultArea = new JTextArea();
        resultArea.setEditable(false);
        JScrollPane scrollPane = new JScrollPane(resultArea);
        
        // Execute button
        JButton executeButton = new JButton("Exécuter");
        executeButton.addActionListener(e -> executeQuery());
        
        // Layout
        JPanel topPanel = new JPanel(new FlowLayout(FlowLayout.LEFT));
        topPanel.add(querySelector);
        topPanel.add(executeButton);
        
        mainPanel.add(topPanel, BorderLayout.NORTH);
        mainPanel.add(scrollPane, BorderLayout.CENTER);
        
        add(mainPanel);
        
        // Center on screen
        setLocationRelativeTo(null);
    }
    
    private void executeQuery() {
    resultArea.setText("");
    try (Connection conn = DatabaseConnection.getConnection()) {
        String query = "";
        switch (querySelector.getSelectedIndex()) {
            case 0:
                query = "SELECT t.id, s1.ville as depart, s2.ville as arrivee, t.date_depart, t.prix_total " +
                       "FROM \"Trajet\" t " +
                       "JOIN \"Station\" s1 ON t.station_depart = s1.id " +
                       "JOIN \"Station\" s2 ON t.station_arrivee = s2.id";
                break;

            case 1:
                query = "SELECT u.nom, u.prenom, u.mail FROM \"Utilisateur\" u " +
                       "JOIN \"Passager\" p ON u.mail = p.mail_passager";
                break;

            case 2:
                query = "SELECT u.nom, u.prenom, p.role, s1.ville as depart, s2.ville as arrivee " +
                       "FROM \"Assignation_Personnel\" ap " +
                       "JOIN \"Personnel\" p ON ap.mail_personnel = p.mail_personnel " +
                       "JOIN \"Utilisateur\" u ON p.mail_personnel = u.mail " +
                       "JOIN \"Troncon\" t ON ap.id_troncon = t.id " +
                       "JOIN \"Station\" s1 ON t.station_depart = s1.id " +
                       "JOIN \"Station\" s2 ON t.station_arrivee = s2.id";
                break;

            case 3:
                query = "SELECT COUNT(*) as total_reservations, " +
                       "AVG(prix_total) as prix_moyen FROM \"Trajet\" t " +
                       "JOIN \"Reservation\" r ON t.id = r.id_trajet";
                break;
        }
            
            try (PreparedStatement pstmt = conn.prepareStatement(query);
                 ResultSet rs = pstmt.executeQuery()) {
                
                StringBuilder result = new StringBuilder();
                while (rs.next()) {
                    switch (querySelector.getSelectedIndex()) {
                        case 0 -> result.append(String.format("Trajet %d: %s -> %s le %s (%.2f€)\n",
                                rs.getInt("id"),
                                rs.getString("depart"),
                                rs.getString("arrivee"),
                                rs.getString("date_depart"),
                                rs.getDouble("prix_total")));
                        
                        case 1 -> result.append(String.format("%s %s (%s)\n",
                                rs.getString("nom"),
                                rs.getString("prenom"),
                                rs.getString("mail")));
                        
                        case 2 -> result.append(String.format("%s %s (%s): %s -> %s\n",
                                rs.getString("nom"),
                                rs.getString("prenom"),
                                rs.getString("role"),
                                rs.getString("depart"),
                                rs.getString("arrivee")));
                        
                        case 3 -> result.append(String.format("Total réservations: %d\nPrix moyen: %.2f€\n",
                                rs.getInt("total_reservations"),
                                rs.getDouble("prix_moyen")));
                    }
                }
                resultArea.setText(result.toString());
            }
        } catch (Exception e) {
            resultArea.setText("Erreur: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    public static void main(String[] args) {
        try {
            UIManager.setLookAndFeel(new FlatLightLaf());
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        SwingUtilities.invokeLater(() -> {
            new MainApp().setVisible(true);
        });
    }
}
