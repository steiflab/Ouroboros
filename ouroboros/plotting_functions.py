
import pandas as pd
import numpy as np
import plotly.graph_objects as go
import anndata as ad
import matplotlib.pyplot as plt
import cartopy.crs as ccrs

from matplotlib import cm
from matplotlib.colors import Normalize

from matplotlib.cm import get_cmap
from plotly.io import write_image
import seaborn as sns


reference_CC_pole_point = [0.86202236, 0.24824865, 0.44191636]

phase_pal_transition = {
    'G1':'#1f77b4',
       'S': '#ff7f0e',
       'G2M': '#2ca02c', 
       'G0': 'black', 
       'G1-G0 transition': '#d62728'}


def is_continuous(series):
    return pd.api.types.is_numeric_dtype(series) and series.nunique() > 10


def make_sphere_surface(radius, points=300):
    phi = np.linspace(0, np.pi, points)
    theta = np.linspace(0, 2 * np.pi, points)
    phi, theta = np.meshgrid(phi, theta)
    x = radius * np.sin(phi) * np.cos(theta)
    y = radius * np.sin(phi) * np.sin(theta)
    z = radius * np.cos(phi)
    return go.Surface(x=x, y=y, z=z, colorscale=[[0, 'lightgray'], [1, 'lightgray']],
                      opacity=1, showscale=False, name='', legendgroup='none',
                      contours=dict(x=dict(show=False), y=dict(show=False), z=dict(show=False)))

def project_above_sphere(x, y, z, radius, offset):
    points = np.stack([x, y, z], axis=1)
    normals = points / np.linalg.norm(points, axis=1, keepdims=True)
    projected_points = normals * (radius + offset)
    return projected_points[:, 0], projected_points[:, 1], projected_points[:, 2]


def make_pole_trace(pole, name, color, width, radius, extension=1.3):
    point = np.array(pole)
    point_norm = point / np.linalg.norm(point) * radius
    opp = -point_norm
    return go.Scatter3d(
        x=[point_norm[0]*extension, opp[0]*extension],
        y=[point_norm[1]*extension, opp[1]*extension],
        z=[point_norm[2]*extension, opp[2]*extension],
        mode='lines',
        line=dict(color=color, width=width),
        name=name
    )


def make_reference_traces(ref, radius, offset, marker_size=5, alpha=0.07):
    traces = []
    ref_pal = phase_pal_transition
    for phase, color in ref_pal.items():
        df = ref[ref['phase'] == phase]
        x, y, z = df['dim1'].values, df['dim2'].values, df['dim3'].values
        x, y, z = project_above_sphere(x, y, z, radius, offset)
        traces.append(go.Scatter3d(x=x, y=y, z=z, mode='markers', marker=dict(size=marker_size, color=color, opacity=alpha),
                                   name=f"Reference {phase}", showlegend=True))
    return traces





def make_new_traces(z_df, radius, offset, color_by='KNN_phase', palette=None, marker_size=3, is_continuous=False):
    traces = []
    if is_continuous:
        color_vals = z_df[color_by].values
        x, y, z = z_df['dim1'].values, z_df['dim2'].values, z_df['dim3'].values
        x, y, z = project_above_sphere(x, y, z, radius, offset)
        traces.append(go.Scatter3d(x=x, y=y, z=z, mode='markers',
                                   marker=dict(size=marker_size, color=color_vals, coloraxis='coloraxis'),
                                   name=color_by, showlegend=False))
        if z_df[color_by].isna().any():
            na_mask = z_df[color_by].isna()
            x_na, y_na, z_na = project_above_sphere(x[na_mask], y[na_mask], z[na_mask], radius, offset)
            traces.append(go.Scatter3d(x=x_na, y=y_na, z=z_na, mode='markers',
                                       marker=dict(size=marker_size, color='grey'),
                                       name='NA', showlegend=True))
    else:
        if palette is None:
            palette = {}
        for phase, color in palette.items():
            phase_df = z_df[z_df[color_by] == phase]
            x, y, z = phase_df['dim1'].values, phase_df['dim2'].values, phase_df['dim3'].values
            x, y, z = project_above_sphere(x, y, z, radius, offset)
            traces.append(go.Scatter3d(x=x, y=y, z=z, mode='markers',
                                       marker=dict(size=marker_size, color=color),
                                       name=phase))
    return traces




def make_velocity_vectors(z_df, velocity):
    vel = velocity[['dim1', 'dim2', 'dim3']].to_numpy()
    umap = z_df[['dim1', 'dim2', 'dim3']].to_numpy()
    arrows = [
        go.Scatter3d(x=[u[0], u[0] + v[0]], y=[u[1], u[1] + v[1]], z=[u[2], u[2] + v[2]],
                     mode='lines', line=dict(color='black', width=1), showlegend=False, legendgroup='velocity')
        for u, v in zip(umap, vel)
    ]
    cone = go.Cone(x=umap[:, 0] + vel[:, 0], y=umap[:, 1] + vel[:, 1], z=umap[:, 2] + vel[:, 2],
                   u=vel[:, 0], v=vel[:, 1], w=vel[:, 2], sizemode="scaled", sizeref=0.5, anchor="tail",
                   colorscale=[[0, "black"], [1, "black"]], showscale=False, name='Velocity Vectors', showlegend=True,
                   legendgroup='velocity')
    return arrows, cone



def seaborn_to_plotly(palette_name, n_colors=256):
    cmap = cm.get_cmap(palette_name)  # use matplotlib for everything
    colors = [cmap(i / (n_colors - 1))[:3] for i in range(n_colors)]
    return [[i / (n_colors - 1), f"rgb({r*255:.0f},{g*255:.0f},{b*255:.0f})"] for i, (r, g, b) in enumerate(colors)]

def normalize_colormap(cmap_name='mako', vmin=-1, vmax=0, n_colors=256):
    norm = Normalize(vmin=vmin, vmax=vmax)
    cmap = cm.get_cmap(cmap_name)
    colors = [cmap(norm(np.linspace(vmin, vmax, n_colors)[i]))[:3] for i in range(n_colors)]
    return [[i / (n_colors - 1), f"rgb({r*255:.0f},{g*255:.0f},{b*255:.0f})"] for i, (r, g, b) in enumerate(colors)]



def plot_sphere(z_df, colour_by = 'KNN_phase', palette = None, ref = None, velocity = None, marker_size = 2, cycle_pole = reference_CC_pole_point):
    fig_data = []

    # Sphere properties
    mtx = z_df[['dim1', 'dim2', 'dim3']].values
    radius = np.mean(np.linalg.norm(mtx, axis=1)) - 0.01
    offset = 0.01 * radius  # Slight offset above the sphere

    # Make grey surface of sphere
    sphere = make_sphere_surface(radius)
    fig_data.append(sphere)
  
    fig_data.append(make_pole_trace(cycle_pole, 'Cell cycle pole', color='grey', width=25, radius = radius, extension=1.3))

    if ref is not None:
        ref_traces = make_reference_traces(ref, radius, offset, marker_size=5, alpha=0.07)
        fig_data += ref_traces

    is_cont = is_continuous(z_df[colour_by])
    if is_cont:
        if isinstance(palette, str):
            palette = seaborn_to_plotly(palette)
        elif palette is None and colour_by == 'cell_cycle_pseudotime':
            palette = normalize_colormap('rocket_r', vmin=0, vmax=1)
        elif palette is None and colour_by == 'dormancy_depth':
            palette = normalize_colormap('mako', vmin=-1, vmax=0)
        elif palette is None:
            palette = seaborn_to_plotly('viridis')
        
    else: 
        if colour_by == 'KNN_phase':
            palette = phase_pal_transition
        elif colour_by != 'KNN_phase' and palette is None:
            # Generate a palette if none is provided
            print('generating_palette')
            unique_labels = z_df[colour_by].unique()
            cmap = get_cmap('tab20')
            palette = {
                label: '#{:02x}{:02x}{:02x}'.format(
                    int(r * 255), int(g * 255), int(b * 255)
                )
                for i, label in enumerate(unique_labels)
                for r, g, b, _ in [cmap(i / max(len(unique_labels) - 1, 1))]
            }
        else:
            palette = palette 


    scatter_traces = make_new_traces(z_df, radius, offset, color_by=colour_by, palette=palette, marker_size=marker_size, is_continuous=is_cont)
    fig_data += scatter_traces

    if velocity is not None:
        arrow_traces, cone_trace = make_velocity_vectors(z_df, velocity)
        fig_data += arrow_traces + [cone_trace]
        
    fig = go.Figure(data=fig_data)
    
    fig.update_layout(
        margin=dict(l=5, r=5, t=5, b=5),
        scene=dict(
            xaxis=dict(showgrid=False, zeroline=False, showticklabels=False, visible=False),
            yaxis=dict(showgrid=False, zeroline=False, showticklabels=False, visible=False),
            zaxis=dict(showgrid=False, zeroline=False, showticklabels=False, visible=False)
        ),
        legend=dict(
            x=0.9, 
            y=0.3, 
            font=dict(size=14),
            itemsizing='constant',  
        ),
        showlegend=True,
    )
    
    if is_cont:
        fig.update_layout(
            coloraxis=dict(
                colorscale=palette,
                colorbar=dict(
                    title=dict(
                        text=colour_by.replace('_', ' ').capitalize(),
                        side="top",
                        font=dict(size=22)
                    ),
                    len=0.4,
                    thickness=20,
                    x=0.9,
                    y=0.65,
                    yanchor="middle"
                )
            )
        )

    fig.show()

