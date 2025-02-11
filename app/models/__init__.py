from geoalchemy2 import Geometry
from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

class Project(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    address = db.Column(db.String(200))
    total_units = db.Column(db.Integer)
    geometry = db.Column(Geometry('POINT'))  # For point locations
    boundary = db.Column(Geometry('POLYGON'))  # For project boundaries